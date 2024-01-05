PACKAGE_NAME="Bluetooth Linux"
PACKAGE_VERSION="5.71"
PACKAGE_SRC="https://cdn.kernel.org/pub/linux/bluetooth/bluez-${PACKAGE_VERSION}.tar.xz"
PACKAGE_DEPENDS="kernel-headers glibc alsa-lib dbus sbc glib libical readline json-c"

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   PKG_CONFIG_PATH="${BUILD_PKG_CONFIG_LIBDIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --localstatedir=/data/bt/bluez \
	   --sysconfdir=/etc \
	   --disable-manpages --enable-logger \
	   --enable-threads --enable-nfc --enable-library \
	   --enable-tools --enable-deprecated \
	   --disable-systemd --disable-udev --disable-obex \
	   --with-sysroot=${STAGING_DIR}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	# replace original
	mv -f ${STAGING_DIR}/usr/libexec/bluetooth/bluetoothd ${STAGING_DIR}/usr/bin/bluetoothd

	for NAME in ibeacon eddystone \
		btproxy btmgmt btinfo btconfig btattach \
		bluetooth-player bluemoon bdaddr bccmd; do
	cp -v tools/${NAME} ${STAGING_DIR}/usr/bin/ || true
	done
}
