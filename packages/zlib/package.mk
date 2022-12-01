PACKAGE_NAME="zlib"
PACKAGE_VERSION="1.2.13"
PACKAGE_SRC="https://github.com/madler/zlib/archive/refs/tags/v${PACKAGE_VERSION}.tar.gz"

configure_package() {
	#LDPREFIX="-L${STAGING_DIR}/lib -Wl,--rpath-link=${STAGING_DIR}/${INSTALL_PREFIX}/lib -Wl,--rpath-link=${STAGING_DIR}/lib"
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS=${BUILD_LDFLAGS} \
		 CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
		 PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
		 ./configure --prefix=${INSTALL_PREFIX}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
