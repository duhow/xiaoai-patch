PACKAGE_NAME="htop"
PACKAGE_VERSION="3.2.1"
PACKAGE_SRC="https://github.com/htop-dev/htop/archive/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc ncurses"

configure_package() {
  ./autogen.sh
	CC=${BUILD_CC} CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
		 ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} --disable-unicode
}

make_package() {
	CC=${BUILD_CC} make -j${MAKE_JOBS}
}

install_package() {
	CC=${BUILD_CC} make DESTDIR=${STAGING_DIR} install
}
