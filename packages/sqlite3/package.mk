PACKAGE_NAME="SQLite"
PACKAGE_VERSION="3.36.0"
PACKAGE_SRC="https://github.com/mackyle/sqlite/archive/refs/tags/version-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="zlib readline"

configure_package() {
	CC="${BUILD_CC}" CFLAGS="-DSQLITE_ENABLE_UNLOCK_NOTIFY ${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
