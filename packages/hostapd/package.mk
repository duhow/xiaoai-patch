PACKAGE_NAME="hostapd"
PACKAGE_VERSION="2.9"
PACKAGE_SRC="https://w1.fi/releases/hostapd-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="base dbus openssl libnl"

configure_package(){
	cd ${PACKAGE_NAME}

	# copy default config
	grep -ve '^#' -ve '^$' defconfig > .config
	#'
	echo "CONFIG_IEEE80211N=y" >> .config
}

make_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	make -j${MAKE_JOBS} \
		CC=${BUILD_CC} LDFLAGS="${BUILD_LDFLAGS}" EXTRA_CFLAGS="${BUILD_CFLAGS}"
}

install_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	make install \
		DESTDIR=${STAGING_DIR} BINDIR=${INSTALL_PREFIX}/sbin \
		CC=${BUILD_CC} LDFLAGS="${BUILD_LDFLAGS}" EXTRA_CFLAGS="${BUILD_CFLAGS}"
}
