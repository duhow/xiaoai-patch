PACKAGE_NAME="GNU Toolchain for the A-profile Architecture"
PACKAGE_VERSION="7.4.1-2019.02"
PACKAGE_SUBVERSION="7.4-2019.02"
BUILD_TARGET="arm-linux-gnueabihf"

if [ "${BUILD_ARCH}" = "aarch64" || "${MODEL}" = "s12" ]; then
BUILD_TARGET="aarch64-linux-gnu"
fi

PACKAGE_SRC="https://releases.linaro.org/components/toolchain/binaries/${PACKAGE_SUBVERSION}/${BUILD_TARGET}/gcc-linaro-${PACKAGE_VERSION}-x86_64_${BUILD_TARGET}.tar.xz"

if [ "${HOST_ARCH}" = "aarch64" ]; then
PACKAGE_VERSION="10.2-2020.11"
PACKAGE_SRC="https://developer.arm.com/-/media/Files/downloads/gnu-a/${PACKAGE_VERSION}/binrel/gcc-arm-${PACKAGE_VERSION}-aarch64-arm-none-linux-gnueabihf.tar.xz"
fi


on_exit_build() {
	TOOLCHAIN_DIR=$(pwd)
	case ${BUILD_ARCH} in
	"armv7")	
		# using GCC-10
		[[ "${HOST_ARCH}" = "aarch64" ]] && BUILD_TARGET="arm-none-linux-gnueabihf"

				BUILD_LDFLAGS="-L${STAGING_DIR}/lib -L${STAGING_DIR}/${INSTALL_PREFIX}/lib -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib/pulseaudio -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib/private -Wl,--rpath=${INSTALL_PREFIX}/${BUILD_TARGET}/lib -Wl,--rpath=${INSTALL_PREFIX}/lib -Wl,--dynamic-linker=/lib/ld-linux-armhf.so.3 -Os"
		;;
	"aarch64")
				BUILD_LDFLAGS="-L${STAGING_DIR}/lib -L${STAGING_DIR}/${INSTALL_PREFIX}/lib -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib/pulseaudio -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib/private -Wl,--rpath=${INSTALL_PREFIX}/${BUILD_TARGET}/lib -Wl,--rpath=${INSTALL_PREFIX}/lib -Wl,--dynamic-linker=/lib/ld-linux-armhf.so.3 -Os"
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
