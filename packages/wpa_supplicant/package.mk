PACKAGE_NAME="wpa_supplicant"
PACKAGE_VERSION="2.9"
PACKAGE_SRC="https://w1.fi/releases/wpa_supplicant-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="base openssl dbus hostapd"

configure_package(){
	cd ${PACKAGE_NAME}

	# copy default config
	grep -ve '^#' -ve '^$' defconfig > .config
	#'

	# disable settings
	for CFGNAME in AP P2P DPP WPS SAE PKCS12 SMARTCARD IEEE80211AC WIFI_DISPLAY; do
	  sed -i "s/CONFIG_${CFGNAME}=y/#CONFIG_${CFGNAME}=y/" .config
	done
}

make_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	make -j${MAKE_JOBS} \
		CC=${BUILD_CC} LDFLAGS="${BUILD_LDFLAGS}" EXTRA_CFLAGS="${BUILD_CFLAGS}"
}

install_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	make install \
		DESTDIR=${STAGING_DIR} \
		BINDIR=${INSTALL_PREFIX}/sbin LIBDIR=${INSTALL_PREFIX}/lib INCDIR=${INSTALL_PREFIX}/include \
		CC=${BUILD_CC} LDFLAGS="${BUILD_LDFLAGS}" EXTRA_CFLAGS="${BUILD_CFLAGS}"
}
