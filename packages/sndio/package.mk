PACKAGE_NAME="sndio"
PACKAGE_VERSION="1.10.0"
PACKAGE_SRC="https://github.com/ratchov/sndio/archive/refs/tags/v${PACKAGE_VERSION}.tar.gz"

configure_package() {
	./configure --prefix=${INSTALL_PREFIX}
}

make_package() {
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
