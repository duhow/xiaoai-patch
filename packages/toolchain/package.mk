PACKAGE_NAME="GNU Toolchain for the A-profile Architecture"
PACKAGE_VERSION="GCC 8.3-2019.03"
PACKAGE_SRC="https://developer.arm.com/-/media/Files/downloads/gnu-a/8.3-2019.03/binrel/gcc-arm-8.3-2019.03-x86_64-arm-linux-gnueabihf.tar.xz"

on_exit_build() {
	TOOLCHAIN_DIR=$(pwd)

	BUILD_TARGET="arm-linux-gnueabihf"
  BUILD_LDFLAGS="-L${STAGING_DIR}/${INSTALL_PREFIX}/lib -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib \
								-Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib/pulseaudio \
								-Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib/private \
								-Wl,--rpath=${INSTALL_PREFIX}/${BUILD_TARGET}/lib \
								-Wl,--rpath=${INSTALL_PREFIX}/lib \
								-Wl,--dynamic-linker=/lib/ld-linux-armhf.so.3"

	BUILD_CC="${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}-gcc"
	BUILD_CXX="${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}-g++"
    BUILD_CFLAGS="-I${STAGING_DIR}/${INSTALL_PREFIX}/include"
	BUILD_AR="${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}-ar"
	BUILD_RANLIB="${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}-ranlib"
	BUILD_OBJCOPY="${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}-objcopy"
	BUILD_STRIP="${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}-strip"
	BUILD_PKG_CONFIG_LIBDIR="${STAGING_DIR}/${INSTALL_PREFIX}/lib/pkgconfig"
	BUILD_PKG_CONFIG_SYSROOT_DIR="${STAGING_DIR}"
	export PATH="${TOOLCHAIN_DIR}/bin:${PATH}"

	TOOLCHAIN_CMAKE="${TOOLCHAIN_DIR}/config/cmake-toolchain.txt"
	mkdir -p ${TOOLCHAIN_DIR}/config
	in_to_out ${PACKAGE_DIR}/config/cmake-toolchain.txt.in ${TOOLCHAIN_CMAKE}

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
