PACKAGE_NAME="JACK Audio Connection Kit"
PACKAGE_VERSION="1.9.20"
PACKAGE_SRC="https://github.com/jackaudio/jack2/archive/v${PACKAGE_VERSION}.tar.gz"

configure_package() {
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS} -ltinfo" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" ./waf configure --prefix=${INSTALL_PREFIX}
}

make_package() {
	./waf -j${MAKE_JOBS}
}

install_package() {
	./waf install --destdir=${STAGING_DIR}
}
