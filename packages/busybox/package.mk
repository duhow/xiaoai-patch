PACKAGE_NAME="BusyBox"
PACKAGE_VERSION="1.32.0"
PACKAGE_SRC="https://busybox.net/downloads/busybox-${PACKAGE_VERSION}.tar.bz2"
PACKAGE_DEPENDS="base"

configure_package() {
	CC=${BUILD_CC} make defconfig CROSS_COMPILE=${BUILD_TARGET}- CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" \
	     CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}"
}

premake_package() {
	echo "configuring additional functions"
	# https://busybox.net/FAQ.html#touch_config
	sleep 1

	sed -i '/CONFIG_LOCK/c\CONFIG_LOCK=y' .config
	sleep 1
	sed -i "/CONFIG_PREFIX/c\CONFIG_PREFIX=\"${STAGING_DIR}\"" .config
	sleep 1
}

make_package() {
	CC=${BUILD_CC} make -j${MAKE_JOBS} CROSS_COMPILE=${BUILD_TARGET}-
}

install_package() {
	mkdir -p ${STAGING_DIR}/bin
	cp -v ${PACKAGE_SRC_DIR}/busybox ${STAGING_DIR}/bin/busybox
}

postinstall_package() {
	# we don't need init, as it would replace default openwrt init ELF!
	rm -f ${STAGING_DIR}/sbin/init

	for NAME in base64 bc dos2unix ftpd httpd ip ipaddr lsof nbd-client nproc \
		patch realpath sha1sum sha256sum sha3sum sha512sum stat tac tftp tftpd unix2dos xxd; do
		ln -vsf busybox ${STAGING_DIR}/bin/${NAME}
	done
}

