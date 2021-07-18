PACKAGE_NAME="dnsmasq"
PACKAGE_VERSION="2.85"
PACKAGE_SRC="https://thekelleys.org.uk/dnsmasq/dnsmasq-${PACKAGE_VERSION}.tar.xz"
PACKAGE_DEPENDS="base"  # dbus is optional

make_package() {
	make -j${MAKE_JOBS} \
		PREFIX=${INSTALL_PREFIX} DESTDIR=${STAGING_DIR} \
		CC=${BUILD_CC} LDFLAGS="${BUILD_LDFLAGS}" CFLAGS="${BUILD_CFLAGS}"
}

install_package() {
	make install \
		PREFIX=${INSTALL_PREFIX} DESTDIR=${STAGING_DIR} \
		CC=${BUILD_CC} LDFLAGS="${BUILD_LDFLAGS}" CFLAGS="${BUILD_CFLAGS}"
}
