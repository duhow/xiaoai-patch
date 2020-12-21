PACKAGE_NAME="Avahi"
PACKAGE_VERSION="0.8"
PACKAGE_DEPENDS="libdaemon libevent glib"
PACKAGE_SRC="http://avahi.org/download/avahi-0.8.tar.gz"

configure_package() {
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} --sysconfdir=${INSTALL_PREFIX}/etc --with-distro=debian --disable-qt3 --disable-qt4 --disable-qt5 --disable-gtk --disable-gtk3 --disable-python --disable-mono --disable-manpages
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
