PACKAGE_NAME="Yet Another JSON Library"
PACKAGE_VERSION="2.1.0"
PACKAGE_SRC="https://github.com/lloyd/yajl/archive/2.1.0.tar.gz"

configure_package() {
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" PKG_CONFIG_LIBDIR="${MPD_BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" ./configure -p ${INSTALL_PREFIX}
}

make_package() {
	make -j${MAKE_JOBS} distro
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	in_to_out ${PACKAGE_DIR}/config/yajl.pc.in ${STAGING_DIR}/${INSTALL_PREFIX}/lib/pkgconfig/yajl.pc
}