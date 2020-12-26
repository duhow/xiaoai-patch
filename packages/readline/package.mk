PACKAGE_NAME="GNU Readline"
PACKAGE_VERSION="8.1"
PACKAGE_SRC="https://ftp.gnu.org/gnu/readline/readline-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="ncurses"

configure_package() {
	CC=${BUILD_CC} CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET}
}

make_package() {
	make -j${MAKE_JOBS} SHLIB_LIBS=-lncurses
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
