PACKAGE_NAME="ncurses"
PACKAGE_VERSION="6.2"
PACKAGE_SRC="ftp://ftp.gnu.org/gnu/ncurses/ncurses-6.2.tar.gz"

configure_package() {
	# specifying --with-termlib is important because libcdio requires it (libtinfo)
	CC=${BUILD_CC} CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" ./configure --with-termlib --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} --disable-stripping --with-shared
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	in_to_out ${PACKAGE_DIR}/config/ncurses.pc.in ${STAGING_DIR}/${INSTALL_PREFIX}/lib/pkgconfig/ncurses.pc
}
