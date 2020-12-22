PACKAGE_NAME="D-Bus"
PACKAGE_VERSION="1.13.18"
PACKAGE_SRC="https://dbus.freedesktop.org/releases/dbus/dbus-1.13.18.tar.xz"
PACKAGE_DEPENDS="expat"


configure_package() {
	#CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}"
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" \
	   CXX="${BUILD_CXX}" \
	   LDFLAGS="${BUILD_LDFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
