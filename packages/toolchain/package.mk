PACKAGE_NAME="GNU Toolchain for the A-profile Architecture"
PACKAGE_VERSION="GCC 7.4-2019.02"
PACKAGE_SRC="https://releases.linaro.org/components/toolchain/binaries/7.4-2019.02/arm-linux-gnueabihf/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf.tar.xz"

if [ "${HOST_ARCH}" = "aarch64" ]; then
PACKAGE_VERSION="10.2-2020.11"
PACKAGE_SRC="https://developer.arm.com/-/media/Files/downloads/gnu-a/${PACKAGE_VERSION}/binrel/gcc-arm-${PACKAGE_VERSION}-aarch64-arm-none-linux-gnueabihf.tar.xz"
fi

on_exit_build() {
	TOOLCHAIN_DIR=$(pwd)
	case ${BUILD_ARCH} in
	"arm")	
		BUILD_TARGET="arm-linux-gnueabihf"
        BUILD_LDFLAGS="-L${STAGING_DIR}/${INSTALL_PREFIX}/lib -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib/pulseaudio -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib/private -Wl,--rpath-link=${TOOLCHAIN_DIR}/${BUILD_TARGET}/libc/lib -Wl,--rpath=${INSTALL_PREFIX}/${BUILD_TARGET}/lib -Wl,--rpath=${INSTALL_PREFIX}/lib -Wl,--dynamic-linker=${INSTALL_PREFIX}/${BUILD_TARGET}/lib/ld-linux-armhf.so.3"
		;;
	"armv7")	
		BUILD_TARGET="arm-linux-gnueabihf"

		# using GCC-10
		[[ "${HOST_ARCH}" = "aarch64" ]] && BUILD_TARGET="arm-none-linux-gnueabihf"

        BUILD_LDFLAGS="-L${STAGING_DIR}/lib -L${STAGING_DIR}/${INSTALL_PREFIX}/lib -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib/pulseaudio -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib/private -Wl,--rpath=${INSTALL_PREFIX}/${BUILD_TARGET}/lib -Wl,--rpath=${INSTALL_PREFIX}/lib -Wl,--dynamic-linker=/lib/ld-linux-armhf.so.3 -Os"
		;;
	"x86")
		BUILD_TARGET="i686-linux"
		BUILD_LDFLAGS="-L${STAGING_DIR}/${INSTALL_PREFIX}/lib -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib/pulseaudio -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib/private -Wl,--rpath=${INSTALL_PREFIX}/${BUILD_TARGET}/lib -Wl,--rpath=${INSTALL_PREFIX}/lib -Wl,--dynamic-linker=${INSTALL_PREFIX}/${BUILD_TARGET}/lib/ld-linux.so.2"
		# bison in this toolchain is looking at wrong paths, use system one instead
		# https://github.com/bootlin/toolchains-builder/issues/17
		if [[ -e ${TOOLCHAIN_DIR}/bin/bison ]]; then
			mv ${TOOLCHAIN_DIR}/bin/bison ${TOOLCHAIN_DIR}/bin/bison.disabled
		fi
		# Use system's Python 
		if [[ -e ${TOOLCHAIN_DIR}/bin/python3 ]]; then
			mv ${TOOLCHAIN_DIR}/bin/python3 ${TOOLCHAIN_DIR}/bin/python3.disabled
		fi
        # Use system's autoconf
		if [[ -e ${TOOLCHAIN_DIR}/bin/autoconf ]]; then
			mv ${TOOLCHAIN_DIR}/bin/autoconf ${TOOLCHAIN_DIR}/bin/autoconf.disabled
		fi
		# Use system's autoreconf
		if [[ -e ${TOOLCHAIN_DIR}/bin/autoreconf ]]; then
			mv ${TOOLCHAIN_DIR}/bin/autoreconf ${TOOLCHAIN_DIR}/bin/autoreconf.disabled
		fi
		# Use system's aclocal
		if [[ -e ${TOOLCHAIN_DIR}/bin/aclocal ]]; then
			mv ${TOOLCHAIN_DIR}/bin/aclocal ${TOOLCHAIN_DIR}/bin/aclocal.disabled
		fi
        # Use system's autoheader
		if [[ -e ${TOOLCHAIN_DIR}/bin/autoheader ]]; then
			mv ${TOOLCHAIN_DIR}/bin/autoheader ${TOOLCHAIN_DIR}/bin/autoheader.disabled
		fi
        # Use system's autom4te
		if [[ -e ${TOOLCHAIN_DIR}/bin/autom4te ]]; then
			mv ${TOOLCHAIN_DIR}/bin/autom4te ${TOOLCHAIN_DIR}/bin/autom4te.disabled
		fi
		# Use system's libtoolize
		if [[ -e ${TOOLCHAIN_DIR}/bin/libtoolize ]]; then
			mv ${TOOLCHAIN_DIR}/bin/libtoolize ${TOOLCHAIN_DIR}/bin/libtoolize.disabled
		fi
        # Use system's automake
		if [[ -e ${TOOLCHAIN_DIR}/bin/automake ]]; then
			mv ${TOOLCHAIN_DIR}/bin/automake ${TOOLCHAIN_DIR}/bin/automake.disabled
		fi
		;;
	*)
		echo_error "Error: Unknown target '${BUILD_ARCH}'. Toolchain setup failed."
		return 1
		;;
	esac

	BUILD_CC="${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}-gcc"
	BUILD_CXX="${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}-g++"
	BUILD_CFLAGS="-I${STAGING_DIR}/${INSTALL_PREFIX}/include -Os"
	BUILD_AR="${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}-ar"
	BUILD_RANLIB="${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}-ranlib"
	BUILD_OBJCOPY="${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}-objcopy"
	BUILD_STRIP="${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}-strip"
	BUILD_PKG_CONFIG_LIBDIR="${STAGING_DIR}/${INSTALL_PREFIX}/lib/pkgconfig"
	BUILD_PKG_CONFIG_SYSROOT_DIR="${STAGING_DIR}"
	export PATH="${TOOLCHAIN_DIR}/bin:${PATH}"

	TOOLCHAIN_CMAKE="${TOOLCHAIN_DIR}/config/cmake-toolchain.txt"
	TOOLCHAIN_SYSROOT_CMAKE="${TOOLCHAIN_DIR}/config/cmake-toolchain-sysroot.txt"
	TOOLCHAIN_MESON="${TOOLCHAIN_DIR}/config/meson-cross-file.txt"
	mkdir -p ${TOOLCHAIN_DIR}/config

	in_to_out ${PACKAGE_DIR}/config/cmake-toolchain.txt.in ${TOOLCHAIN_CMAKE}
	in_to_out ${PACKAGE_DIR}/config/cmake-toolchain-sysroot.txt.in ${TOOLCHAIN_SYSROOT_CMAKE}
	in_to_out ${PACKAGE_DIR}/config/meson-cross-file.in ${TOOLCHAIN_MESON}

	# HACK to avoid errors with LDFLAGS files not found
	for FILE in /lib/libc.so.6 /lib/ld-linux-armhf.so.3 /usr/lib/libc_nonshared.a /lib/libpthread.so.0 /usr/lib/libpthread_nonshared.a ; do
		[ ! -e ${FILE} ] && ln -s ${STAGING_DIR}/${FILE} ${FILE}
	done

	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
	echo "TOOLCHAIN_DIR=\"${TOOLCHAIN_DIR}\""
	echo "BUILD_TARGET=\"${BUILD_TARGET}\""
	echo "BUILD_CC=\"${BUILD_CC}\""
	echo "BUILD_CXX=\"${BUILD_CXX}\""
	echo "BUILD_AR=\"${BUILD_AR}\""
	echo "BUILD_RANLIB=\"${BUILD_RANLIB}\""
	echo "BUILD_OBJCOPY=\"${BUILD_OBJCOPY}\""
	echo "BUILD_STRIP=\"${BUILD_STRIP}\""
	echo "BUILD_CFLAGS=\"${BUILD_CFLAGS}\""
	echo "BUILD_LDFLAGS=\"${BUILD_LDFLAGS}\""
	echo "BUILD_PKG_CONFIG_LIBDIR=\"${BUILD_PKG_CONFIG_LIBDIR}\""
	echo "BUILD_PKG_CONFIG_SYSROOT_DIR=\"${BUILD_PKG_CONFIG_SYSROOT_DIR}\""
	echo "PATH=\"${PATH}\""
	echo "TOOLCHAIN_CMAKE=\"${TOOLCHAIN_CMAKE}\""
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}
