PACKAGE_NAME="echo canceller"
PACKAGE_VERSION="master"
#PACKAGE_SRC="https://github.com/voice-engine/ec/archive/${PACKAGE_VERSION}.tar.gz"
PACKAGE_SRC="https://github.com/danielk117/ec/archive/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="alsa-lib alsa-plugin-fifo speexdsp"

make_package() {
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	   PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   PKG_CONFIG_PATH="${BUILD_PKG_CONFIG_LIBDIR}" \
	   \
	   make -j${MAKE_JOBS} \
	   \
	   CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDLIBS="${BUILD_LDFLAGS} -ldl -lm -Wl,-Bstatic -Wl,-Bdynamic -lrt -lpthread -lasound -lspeexdsp" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	   PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   PKG_CONFIG_PATH="${BUILD_PKG_CONFIG_LIBDIR}"
}

install_package() {
	cp -vf ec ec_hw ${STAGING_DIR}/usr/bin
}
