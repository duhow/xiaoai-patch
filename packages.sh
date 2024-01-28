#!/bin/bash

# Forked from https://github.com/patrickkfkan/volumio-build-mpd - thanks! :)

echo_info() {
    echo -e "\e[1;32m$1 \e[0m"
}

echo_notice() {
    echo -e "\e[1;34m$1 \e[0m"
}

echo_warning() {
    echo -e "\e[1;33m$1 \e[0m"
}

echo_error() {
    echo -e "\e[1;31m$1 \e[0m"
    [ -n "${GITHUB_ACTIONS}" ] && echo "::error::$1"
}

echo_stage() {
    echo -e "\e[36m$1 \e[0m"
}

check_clean_build_necessary() {
    local last_build_config="${BUILD_DIR}/build.config"
    if [[ -f ${last_build_config} ]]; then
        local last_build_prefix=$(source ${last_build_config}; echo "${prefix}")
        if [[ "${last_build_prefix}" != "${INSTALL_PREFIX}" ]]; then
            echo_error "Detected previous build with different prefix (${last_build_prefix})"
            echo "You need to clean the previous build first by running:"
            echo "./build.sh clean --target=${BUILD_ARCH}"
            return 0
        fi
    fi
    return 1
}

write_build_config() {
    local build_config="${BUILD_DIR}/build.config"
    echo "target=${BUILD_ARCH}" > ${build_config}
    echo "prefix=${INSTALL_PREFIX}" >> ${build_config}
    echo "output=${TARGET_PACKAGE_FILENAME}" >> ${build_config}
    echo "j=${MAKE_JOBS}" >> ${build_config}
}

show_help() {
    cat << EOF
Build usage:
./build.sh --prefix=PREFIX -jLEVEL

Defaults for the options are specified in brackets.

Build options:
  --prefix=PREFIX         the path to compile files
  -jLEVEL                 set the make concurrency level to LEVEL [1]

Other usage:
./build.sh [clean or distclean]

Clean options:
  clean                   clear files and directories created during build
  distclean               same as clean, but also clear downloaded package
                          sources
EOF

}

do_clean() {
    local arch
    if [[ ! -z "${BUILD_ARCH}" ]]; then
        arch="${BUILD_ARCH}"
    else
        arch="all targets"
    fi
    echo_stage "Cleaning build for ${arch}..."
    local dirs_to_clean=("${BUILD_DIR}" "${STAGING_DIR}" "${STAGING_TO_TARGET_DIR}")
    for clean_dir in ${dirs_to_clean[@]}; do
        if [[ -d ${clean_dir} ]]; then
            echo "rm -rf ${clean_dir}"
            rm -rf ${clean_dir}
        fi
    done
}

do_distclean() {
    do_clean
    echo_stage "Cleaning downloaded package sources..."
    local clean_dir="${SRC_DOWNLOAD_DIR}"
    if [[ -d ${clean_dir} ]]; then
        echo "rm -rf ${clean_dir}"
        rm -rf ${clean_dir}
    fi
}

func_exists() {
    declare -F "$1" > /dev/null
}

rand_str() {
    local str_len=$1
    if [[ -z "${str_len}" ]]; then
        str_len="5"
    fi
    echo $(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w ${str_len} | head -n 1)
}

load_package() {
    local package_dir="${WORKSPACE_DIR}/../packages/${PACKAGE}"
    local package_mk="${package_dir}/package.mk"
    if [[ ! -f ${package_mk} ]]; then
        echo_error "Error: Package '${PACKAGE}' does not exist (${package_mk} not found)"
        return 1
    fi
    reset_package_vars
    # load package.mk and set global variables for specified package
    source ${package_mk}
    [[ ! $? -eq 0 ]] && return 1

    PACKAGE_DIR="${package_dir}"
    PACKAGE_SRC_DOWNLOAD_DIR=${SRC_DOWNLOAD_DIR}/${PACKAGE}
    PACKAGE_SRC_DIR=${BUILD_DIR}/${PACKAGE}
    if [[ "${PACKAGE_USE_SEPARATE_BUILD_DIR}" == "true" ]]; then
        PACKAGE_BUILD_DIR=${BUILD_DIR}/${PACKAGE}-build
    else
        PACKAGE_BUILD_DIR=${PACKAGE_SRC_DIR}
    fi

    # load package status file
    PACKAGE_STATUS_FILE=${BUILD_DIR}/${PACKAGE}.status
    if [[ -f ${PACKAGE_STATUS_FILE} ]]; then
        source ${PACKAGE_STATUS_FILE}
        [[ ! $? -eq 0 ]] && return 1
        PACKAGE_LAST_BUILD_ID=${build_id}
        PACKAGE_LAST_BUILD_STATUS=${build_status}
        unset build_id
        unset build_status
    fi
}

init_package() {
    load_package
    [[ ! $? -eq 0 ]] && return 1

    mkdir -p ${PACKAGE_SRC_DOWNLOAD_DIR}
    [[ ! $? -eq 0 ]] && return 1
    mkdir -p ${PACKAGE_SRC_DIR}
    [[ ! $? -eq 0 ]] && return 1
    if [[ "${PACKAGE_USE_SEPARATE_BUILD_DIR}" == "true" ]]; then
        mkdir -p ${PACKAGE_BUILD_DIR}
    fi
}

prepare_clean_dir() {
    local directory=$1
    if [[ -d ${directory} ]]; then
        [[ "$(ls -A ${directory})" ]] && rm -rf ${directory}/* || return 0
    else
        mkdir -p ${directory}
    fi
}

get_src_filename() {
    local src_filename=$(basename "${PACKAGE_SRC}")
    # if last part is "download", return previous folder.
    # used for Sourceforge
    if [[ "${src_filename}" = 'download' ]]; then
        echo "${PACKAGE_SRC}" | awk -F/ '{print $(NF-1)}'
    else
        echo ${src_filename}
    fi
}

download_file() {
    local filename="$1"
    local download_dir="$2"
    local url="$3"

    wget --no-check-certificate --tries=5 --retry-connrefused --waitretry=5 \
         --trust-server-names --progress=bar:force:noscroll \
         -O ${filename} -P "${download_dir}" "${url}"
}

download_package_src() {
    if [[ ! -z "${PACKAGE_SRC}" ]]; then
        local src_filename=`get_src_filename`
        if [[ ! -z "${src_filename}" ]]; then
            if [[ -e "${PACKAGE_SRC_DOWNLOAD_DIR}/${src_filename}" ]] && [[ "`stat -c %s ${PACKAGE_SRC_DOWNLOAD_DIR}/${src_filename}`" -gt 1024 ]]; then
                echo "Using cached download"
            else
                echo "Downloading package source..."
                download_file "${src_filename}" "${PACKAGE_SRC_DOWNLOAD_DIR}" "${PACKAGE_SRC}"
            fi
        else
            echo_error "Error: Invalid package source specified!"
            return 1
        fi
    fi
}

unpack_package_src() {
    if [[ ! -z "${PACKAGE_SRC}" ]]; then
        local src_filename=`get_src_filename`
        local src_file="${PACKAGE_SRC_DOWNLOAD_DIR}/${src_filename}"
        if [[ -e "${src_file}" ]]; then
            echo "Unpacking ${src_file}..."
            if [[ ${src_file: -7} == '.tar.xz' ]]; then
                tar -xf ${src_file} -C ${PACKAGE_SRC_DIR} --strip-components=${PACKAGE_SRC_TAR_STRIP}
            elif [[ ${src_file: -7} == ".tar.gz" || ${src_file: -4} == ".tgz" ]]; then
                tar -xzf ${src_file} -C ${PACKAGE_SRC_DIR} --strip-components=${PACKAGE_SRC_TAR_STRIP}
            elif [[ ${src_file: -8} == ".tar.bz2" ]]; then
                tar -xjf ${src_file} -C ${PACKAGE_SRC_DIR} --strip-components=${PACKAGE_SRC_TAR_STRIP}
            elif [[ ${src_file: -4} == ".zip" ]]; then
                unzip ${src_file} -d ${PACKAGE_SRC_DIR}
            else
                echo_error "Error: Failed to unpack source (unrecognized file type)"
                return 1
            fi
        else
            echo_error "Error: Package source file does not exist!"
            return 1
        fi
    fi

}

apply_patches() {
    local build_dir=${PACKAGE_SRC_DIR}
    local patches_dir=${PACKAGE_DIR}/patches
    if [[ -d ${patches_dir} ]]; then
        local old_dir=$(pwd)
        cd ${build_dir}
        local patch_order_file=${patches_dir}/patch.order
        local patch_file
        if [[ -e ${patch_order_file} ]]; then
            while read -r patch_file_name; do
                if [[ ! -z "${patch_file_name}" ]]; then
                    patch_file=${patches_dir}/${patch_file_name}
                    [[ -e "${patch_file}" ]] || continue
                    echo_stage "Applying patch: ${patch_file}..."
                    patch -p1 < ${patch_file}
                    [[ ! $? -eq 0 ]] && return 1
                fi
            done < ${patch_order_file}
        else
            for patch_file in ${patches_dir}/*.patch; do
                [[ -e "${patch_file}" ]] || continue
                echo_stage "Applying patch: ${patch_file}..."
                patch -p1 < ${patch_file}
                [[ ! $? -eq 0 ]] && return 1
            done
        fi
        cd ${old_dir}
    fi
}

# With our setup, libtool generates .la files with 'dependency_libs' and 'libdir' containing the wrong path.
# It does not take into account DESTDIR when installing packages. This function fixes those wrong paths.
fix_libtool_la() {
    local lib_dir=${STAGING_DIR}/${INSTALL_PREFIX}/lib
    local fixed_list_file=${BUILD_DIR}/fixed-la.list
    if [[ ! -e "${fixed_list_file}" ]]; then
        touch ${fixed_list_file}
    fi
    if [[ -d "${lib_dir}" ]]; then
        for la_file in $(find ${lib_dir} -name "*.la"); do
            [[ -e "${la_file}" ]] || continue
            if [[ -z "$(cat ${fixed_list_file} | grep "${la_file}")" ]]; then
                echo_stage "Fixing libtool archive: ${la_file}"
                sed -i -e "s; ${INSTALL_PREFIX}; ${STAGING_DIR}/${INSTALL_PREFIX};g" -e "s;'${INSTALL_PREFIX};'${STAGING_DIR}/${INSTALL_PREFIX};g" ${la_file}
                echo ${la_file} >> ${fixed_list_file}
            fi
        done
    fi
}

strip_debug() {
    echo_stage "Stripping debug symbols from target..."
    find ${STAGING_TO_TARGET_DIR}/${INSTALL_PREFIX}/{bin,lib} -type f \
       -exec ${BUILD_STRIP} --strip-debug {} \; > /dev/null 2>&1
}

strip_full() {
    echo_stage "Stripping debug symbols from target..."
    find ${STAGING_TO_TARGET_DIR}/${INSTALL_PREFIX}/{bin,lib} -type f \
       -exec ${BUILD_STRIP} {} \; > /dev/null 2>&1
}

in_to_out() {
    local in_file=$1
    local out_file=$2
    if [[ ! -e ${in_file} ]]; then
        echo "Error: Input file ${in_file} does not exist!"
        return 1
    else
        if [[ -d ${out_file} ]]; then
            out_file="${out_file}/${in_file}"
        fi
        if [[ -e ${out_file} ]]; then
            rm ${out_file}
        fi
        [[ ! $? -eq 0 ]] && return 1
        while read -r in_line; do
            eval echo "\"${in_line//\"/\\\"}\"" >> ${out_file}
            [[ ! $? -eq 0 ]] && return 1
        done < ${in_file}
        echo "Generated: ${out_file}"
    fi
}

update_package_status() {
    local build_status=$1
    echo "build_id=\"${BUILD_ID}\"" > ${PACKAGE_STATUS_FILE}
    echo "build_status=\"${build_status}\"" >> ${PACKAGE_STATUS_FILE}
}

enter_build() {
    if [[ ${PACKAGE_LAST_BUILD_STATUS} != "completed" ]] || func_exists "on_enter_build" || func_exists "on_exit_build"; then
        [ -n "${GITHUB_REF}" ] && echo "::group::Build ${PACKAGE}"
        echo_info "Entering build for package '${PACKAGE}'"
        echo "Entering directory ${PACKAGE_SRC_DOWNLOAD_DIR}..."
        cd ${PACKAGE_SRC_DOWNLOAD_DIR}
        if func_exists "on_enter_build"; then
            on_enter_build
        fi
    fi
}

commence_build() {
    update_package_status "commenced"
    [[ ! $? -eq 0 ]] && return 1

    prepare_clean_dir ${PACKAGE_SRC_DIR}
    [[ ! $? -eq 0 ]] && return 1
    if [[ "${PACKAGE_USE_SEPARATE_BUILD_DIR}" == "true" ]]; then
        prepare_clean_dir ${PACKAGE_BUILD_DIR}
        [[ ! $? -eq 0 ]] && return 1
    fi

    download_package_src
    [[ ! $? -eq 0 ]] && return 1

    unpack_package_src
    [[ ! $? -eq 0 ]] && return 1

    apply_patches
    [[ ! $? -eq 0 ]] && return 1

    echo "Entering directory ${PACKAGE_BUILD_DIR}..."
    cd ${PACKAGE_BUILD_DIR}

    local build_stages=" \
            preconfigure_package \
            configure_package \
            premake_package \
            make_package \
            preinstall_package \
            install_package \
            postinstall_package"

    for stage in ${build_stages}; do
        if func_exists ${stage}; then
            echo_stage "Entering ${stage}..."
            ${stage}
            if [[ ! $? -eq 0 ]]; then
                echo "${stage} returned error"
                return 1
            fi
        fi
    done
}

exit_build() {
    local status=$1
    [[ "${status}" == '' ]] && status=0

    local build_status
    if [[ "${status}" == '0' ]]; then
        build_status="completed"
    else
        build_status="failed"
    fi

    if func_exists "on_exit_build"; then
        echo "Entering directory ${PACKAGE_BUILD_DIR}..."
        cd ${PACKAGE_BUILD_DIR}
        on_exit_build
        [[ ! $? -eq 0 ]] && build_status="failed"
    fi

    if [[ ${PACKAGE_LAST_BUILD_STATUS} != "completed" || ${build_status} == "failed" ]]; then
        if [[ ${build_status} != "failed" ]]; then
            fix_libtool_la
            [[ ! $? -eq 0 ]] && build_status="failed"
        fi
        update_package_status ${build_status}
        [[ ! $? -eq 0 ]] && build_status="failed"
    fi

    [ -n "${GITHUB_REF}" ] && echo "::endgroup::"

    if [[ ${build_status} == "failed" ]]; then
        echo_error "Build for package '${PACKAGE}' not completed"
        exit 1
    fi

    if [[ ${PACKAGE_LAST_BUILD_STATUS} != "completed" ]] || func_exists "on_enter_build" || func_exists "on_exit_build"; then
        echo_notice "Leaving build for package '${PACKAGE}'" "bold"
    fi

    reset_package_vars
}

# Criteria to determine if package needs building
# 1. PACKAGE_LAST_BUILD_STATUS is not "completed"; or
# 2. PACKAGE_LAST_BUILD_ID of any of the dependencies IS
# THE SAME AS the current BUILD_ID (that means the dependency 
# has been built in the current build session and should
# therefore trigger a rebuild of packages down the chain)
package_needs_building() {
    if [[ ${PACKAGE_LAST_BUILD_STATUS} != "completed" ]]; then
        return 0
    fi

    if [[ ! -z "${PACKAGE_DEPENDS}" ]]; then
        for depend in ${PACKAGE_DEPENDS}
        do
            local depend_status_file=${BUILD_DIR}/${depend}.status
            if [[ ! -e ${depend_status_file} ]]; then
                echo_error "Error: Cannot obtain status of dependency package"
                return 2
            fi
            source ${depend_status_file}
            [[ ! $? -eq 0 ]] && return 2
            local _build_id="${build_id}"
            local _build_status="${build_status}"
            unset build_id
            unset build_status
            if [[ "${_build_status}" != "completed" ]]; then
                # Build chain should not reach here if dependency failed
                echo_error "Error: Build of a dependency package did not complete"
                return 2
            fi
            if [[ "${_build_id}" == "${BUILD_ID}" ]]; then
                return 0
            fi
        done
    fi

    return 1
}

reset_package_vars() {
    PACKAGE_NAME=""
    PACKAGE_VERSION=""
    PACKAGE_DEPENDS=""
    PACKAGE_SRC=""
    PACKAGE_SRC_TAR_STRIP=1
    PACKAGE_DIR=""
    PACKAGE_SRC_DIR=""
    PACKAGE_BUILD_DIR=""
    PACKAGE_USE_SEPARATE_BUILD_DIR="false"
    PACKAGE_STATUS_FILE=""
    PACKAGE_LAST_BUILD_ID=""
    PACKAGE_LAST_BUILD_STATUS=""
    unset -f on_enter_build
    unset -f preconfigure_package
    unset -f configure_package
    unset -f premake_package
    unset -f make_package
    unset -f preinstall_package
    unset -f install_package
    unset -f postinstall_package
    unset -f on_exit_build
}

staging_to_target() {
    echo_stage "Copying files from staging..."

    local old_dir=$(pwd)
    
    prepare_clean_dir ${STAGING_TO_TARGET_DIR}
    [[ ! $? -eq 0 ]] && return 1

    cp -a ${STAGING_DIR}/* ${STAGING_TO_TARGET_DIR}

    # cleanup unused data
    cd ${STAGING_TO_TARGET_DIR}
    for name in libexec/gcc lib/gcc lib/cmake include man arm-linux-gnueabihf; do
        echo "rm usr/${name}"
        rm -rf usr/${name}
    done

    # some data in usr/share is required, clean the rest
    for name in applications aclocal doc i18n icons info locale man pixmaps tabset gtk-doc; do
        echo "rm usr/share/${name}"
        rm -rf usr/share/${name}
    done

    # var is used for RAM mount, so let's delete it.
    rm -rf var

    # delete unused compilers in target dir
    cd ${STAGING_TO_TARGET_DIR}/usr/bin
    rm gcov* gcc* g++ cpp c++ arm-linux-gnueabihf-*

    # remove .la and .pc files
    echo "cd ${STAGING_TO_TARGET_DIR}/${INSTALL_PREFIX}"
    cd ${STAGING_TO_TARGET_DIR}/${INSTALL_PREFIX}
    for del_file in $(find . -name "*.la" -o -name "*.pc" -o -name "*.a"); do
        [[ -e "${del_file}" ]] || continue
        echo "rm ${del_file}"
        rm ${del_file}
    done

    echo "cd ${old_dir}"
    cd ${old_dir}
}

misc_to_target() {
    echo_stage "Generating extra files..."

    # create links for various config dirs
    #echo_stage "Generating symbolic links..."
    #ln -s /etc ${STAGING_TO_TARGET_DIR}/${INSTALL_PREFIX}/etc
    #ln -s /run ${STAGING_TO_TARGET_DIR}/${INSTALL_PREFIX}/run
    #ln -s /usr/share ${STAGING_TO_TARGET_DIR}/${INSTALL_PREFIX}/share
    #ln -s /var ${STAGING_TO_TARGET_DIR}/${INSTALL_PREFIX}/var
}

create_target_package() {
    echo_stage "Creating binary package..."
    mkdir -p ${TARGET_PACKAGE_DIR}
    # get name of prefix's top directoy (e.g. "/opt/mpd" -> "opt")
    # https://stackoverflow.com/questions/24631866/how-to-get-root-directory-of-given-path-in-bash
    local prefix_top=$(echo "$INSTALL_PREFIX" | cut -d "/" -f2)
    tar -C ${STAGING_TO_TARGET_DIR} -cvzf ${TARGET_PACKAGE_FILE} .
    [[ ! $? -eq 0 ]] && return 1
    echo_stage "Binary package created: ${TARGET_PACKAGE_FILE}"
}

process_package() {
    if [[ -z "$1" ]]; then
        echo "Error: package not specified!"
        exit 1
    fi

    # we keep track of packages processed in the current
    # build session and don't reprocess them
    for processed in "${PACKAGES_PROCESSED[@]}"
    do
        if [ "$processed" == "$1" ] ; then
            return 0
        fi
    done

    PACKAGE=$1
    PACKAGES_PROCESSED+=(${PACKAGE})

    local current_package=${PACKAGE}

    init_package
    [[ ! $? -eq 0 ]] && exit 1

    if [[ ! -z "${PACKAGE_DEPENDS}" ]]; then
        for depend in ${PACKAGE_DEPENDS}
        do
            process_package $depend
        done
        # building dependencies will override global package variables and
        # functions for $current_package, so we need to reinitialize it
        PACKAGE=${current_package}
        init_package
    fi

    package_needs_building; local build_necessary=$?
    [[ ${build_necessary} -eq 2 ]] && exit_build 1
    if [[ ${build_necessary} -eq 0 ]]; then
        PACKAGE_LAST_BUILD_STATUS=""
    fi

    enter_build
    [[ ! $? -eq 0 ]] && exit_build 1

    if [[ ${build_necessary} -eq 0 ]]; then
        commence_build
        [[ ! $? -eq 0 ]] && exit_build 1
    fi

    exit_build
}

WORKSPACE_DIR=$PWD/build-packages

# parse arguments
for i in "$@"
do
case $i in
    --prefix=*)
        INSTALL_PREFIX="${i#*=}"
        shift
        ;;
    -j*)
        MAKE_JOBS="${i#-j}"
        shift
        ;;
    clean|distclean)
        if [[ ! -z "${INSTALL_PREFIX}" ]]; then
            echo "Ignoring option --prefix"
        fi
        if [[ ! -z "${TARGET_PACKAGE_FILE}" ]]; then
            echo "Ignoring option --output"
        fi
        if [[ ! -z "${MAKE_JOBS}" ]]; then
            echo "Ignoring option -j${MAKE_JOBS}"
        fi
        if [[ "${i}" == "clean" ]]; then
            DO_CLEAN="true"
        else
            DO_DISTCLEAN="true"
        fi
        shift
        ;;
    --help)
        show_help
        exit
        ;;
    *)
        echo "Unknown option ${i}"
        show_help
        exit 1
        ;;
esac
done

BUILD_ID=$(rand_str)
BUILD_ARCH="armv7"
if [[ ! -z "${ARCH}" ]]; then
  BUILD_ARCH="${ARCH}"
fi
if [[ -f "squashfs-root/usr/share/mico/version" ]]; then
	BUILD_MODEL=$(grep HARDWARE squashfs-root/usr/share/mico/version | awk '{print $3}' | tr -d "'" | tr "[:lower:]" "[:upper:]")
fi
if [[ ! -z "${MODEL}" ]]; then
	BUILD_MODEL="${MODEL}"
fi
if [[ "${BUILD_MODEL}" = "S12" ]]; then
  BUILD_ARCH="aarch64"
fi
HOST_ARCH=$(uname -m)
ymd=$(date '+%Y%m%d')
PACKAGES_PROCESSED=()
SRC_DOWNLOAD_DIR=${WORKSPACE_DIR}/src
BUILD_DIR=${WORKSPACE_DIR}/build/${BUILD_ARCH}
STAGING_DIR=${WORKSPACE_DIR}/staging/${BUILD_ARCH}
STAGING_TO_TARGET_DIR=${WORKSPACE_DIR}/s2t/${BUILD_ARCH}
TARGET_PACKAGE_DIR=${WORKSPACE_DIR}/targets
INSTALL_PREFIX="/usr"
TARGET_PACKAGE_FILE=${TARGET_PACKAGE_DIR}/bin-${ymd}-${BUILD_ID}.tar.gz

if [[ "${DO_DISTCLEAN}" == "true" ]]; then
    do_distclean
    exit 0
elif [[ "${DO_CLEAN}" == "true" ]]; then
    do_clean
    exit 0
fi

if [[ -z "${MAKE_JOBS}" ]]; then
  MAKE_JOBS=$(nproc)
fi

printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo "Host arch         :  ${HOST_ARCH}"
echo "Target arch       :  ${BUILD_ARCH}"
echo "Model detected    :  ${BUILD_MODEL}"
echo "Prefix            :  ${INSTALL_PREFIX}"
echo "Make concurrency  :  ${MAKE_JOBS}"
echo_warning "\nNote: Prefix will be the path to all binaries in target device"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

check_clean_build_necessary
[[ $? -eq 0 ]] && exit 1

timeout 4 `read -r -p "Process will begin shortly. Press enter or break run (Ctrl+C). " input`

mkdir -p ${SRC_DOWNLOAD_DIR}
mkdir -p ${BUILD_DIR}
mkdir -p ${STAGING_DIR}/${INSTALL_PREFIX}
mkdir -p ${STAGING_DIR}/${INSTALL_PREFIX}/bin
mkdir -p ${STAGING_DIR}/${INSTALL_PREFIX}/lib
mkdir -p ${STAGING_DIR}/${INSTALL_PREFIX}/lib/pkgconfig
mkdir -p ${STAGING_TO_TARGET_DIR}

write_build_config
[[ ! $? -eq 0 ]] && exit 1

PACKAGES_TO_BUILD="update-libs update-binaries support services music python3 aec-cmdline satellite screen improv getevent"

for PKGN in $PACKAGES_TO_BUILD; do 
  process_package $PKGN
  [[ ! $? -eq 0 ]] && exit 1
done

staging_to_target
if [[ ! $? -eq 0 ]]; then
    echo_error "Failed to create target from staging"
    exit 1
fi

misc_to_target
if [[ ! $? -eq 0 ]]; then
    echo_error "Failed to generate extra files for target"
    exit 1
fi

strip_full

create_target_package
if [[ ! $? -eq 0 ]]; then
    echo_error "Failed to create binary package"
    exit 1
fi
