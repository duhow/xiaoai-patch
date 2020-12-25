PACKAGE_NAME="Bluetooth Linux"
PACKAGE_VERSION="5.54"
PACKAGE_SRC="http://www.kernel.org/pub/linux/bluetooth/bluez-${PACKAGE_VERSION}.tar.xz"
PACKAGE_DEPENDS="kernel-headers glibc alsa-lib dbus sbc glib libical"

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   PKG_CONFIG_PATH="${BUILD_PKG_CONFIG_LIBDIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --enable-threads --enable-nfc --enable-library \
	   --disable-systemd --disable-udev -disable-obex \
	   --with-sysroot=${STAGING_DIR}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
