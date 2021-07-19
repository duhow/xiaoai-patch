PACKAGE_NAME="ncurses"
PACKAGE_VERSION="6.2"
PACKAGE_SRC="ftp://ftp.gnu.org/gnu/ncurses/ncurses-${PACKAGE_VERSION}.tar.gz"

preconfigure_package() {
	# update this extern exit call as it breaks build
	sed -i 's/extern "C" void exit.*/extern "C" void exit (int) throw ();/g' c++/etip.h.in
}

configure_package() {
	# specifying --with-termlib is important because libcdio requires it (libtinfo)
	CC=${BUILD_CC} CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
		 PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
		 ./configure --with-termlib --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} --disable-stripping --with-shared
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	in_to_out ${PACKAGE_DIR}/config/ncurses.pc.in ${STAGING_DIR}/${INSTALL_PREFIX}/lib/pkgconfig/ncurses.pc
	for LIBNAME in panel form menu ncurses; do
	  ln -svf lib${LIBNAME}.so ${STAGING_DIR}/${INSTALL_PREFIX}/lib/lib${LIBNAME}w.so
	done

	TERMNAMES_KEEP="ansi dumb linux rxvt rxvt-unicode screen vt100 vt102 vt220 xterm xterm-256color xterm-color"
	for TERMNAME in ${STAGING_DIR}/${INSTALL_PREFIX}/lib/terminfo/?/*; do
	  (echo ${TERMNAMES_KEEP} | grep `basename ${TERMNAME}` -q) || rm -vf ${TERMNAME}
	done
}
