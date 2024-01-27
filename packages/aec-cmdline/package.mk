PACKAGE_NAME="aec_cmdline"
PACKAGE_VERSION="master"
PACKAGE_SRC="https://github.com/dr-ni/aec_cmdline/archive/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="alsa-lib speexdsp"

make_package() {
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	   PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   PKG_CONFIG_PATH="${BUILD_PKG_CONFIG_LIBDIR}" \
	   \
	   make -j${MAKE_JOBS} \
	   \
	   CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS} -ldl -lm -Wl,-Bstatic -Wl,-Bdynamic -lrt -lpthread -lasound -lspeexdsp" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	   PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   PKG_CONFIG_PATH="${BUILD_PKG_CONFIG_LIBDIR}"
}

install_package() {
	cp -vf aec_cmdline ${STAGING_DIR}/usr/bin
}
