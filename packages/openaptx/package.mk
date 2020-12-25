PACKAGE_NAME="openaptX"
PACKAGE_VERSION="1.2.0"
PACKAGE_SRC="https://github.com/Arkq/openaptx/archive/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="libsndfile ffmpeg"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
