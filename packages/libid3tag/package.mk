PACKAGE_NAME="libid3tag"
PACKAGE_VERSION="0.15.1b"
PACKAGE_SRC="ftp://ftp.mars.org/pub/mpeg/libid3tag-0.15.1b.tar.gz"

configure_package() {
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	in_to_out ${PACKAGE_DIR}/config/id3tag.pc.in ${STAGING_DIR}/${INSTALL_PREFIX}/lib/pkgconfig/id3tag.pc
}