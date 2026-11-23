PACKAGE_NAME="D-Bus"
PACKAGE_VERSION="1.14.10"
PACKAGE_SRC="https://gitlab.freedesktop.org/dbus/dbus/-/archive/dbus-${PACKAGE_VERSION}/dbus-dbus-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="expat"

preconfigure_package() {
	autoreconf -fi
}

configure_package() {
	CC="${BUILD_CC}" \
	CXX="${BUILD_CXX}" \
	CFLAGS="${BUILD_CFLAGS} -I${STAGING_DIR}${INSTALL_PREFIX}/include" \
    CXXFLAGS="${BUILD_CFLAGS} -I${STAGING_DIR}${INSTALL_PREFIX}/include" \
    CPPFLAGS="-I${STAGING_DIR}${INSTALL_PREFIX}/include" \
    LDFLAGS="${BUILD_LDFLAGS} -L${STAGING_DIR}${INSTALL_PREFIX}/lib -Wl,-rpath-link,${STAGING_DIR}${INSTALL_PREFIX}/lib" \
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	./configure \
		--build=${MACHTYPE} \
		--host=${BUILD_TARGET} \
		--prefix=${INSTALL_PREFIX} \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--without-x \
		--disable-tests \
		--disable-systemd
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	mkdir -p ${STAGING_DIR}/etc/init.d ${STAGING_DIR}/etc/rc.d

	cp -vf ${PACKAGE_DIR}/config/dbus.init ${STAGING_DIR}/etc/init.d/dbus
	chmod 755 ${STAGING_DIR}/etc/init.d/dbus
	ln -sf ../init.d/dbus ${STAGING_DIR}/etc/rc.d/S60dbus
}
