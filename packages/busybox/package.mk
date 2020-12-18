PACKAGE_NAME="BusyBox"
PACKAGE_VERSION="1.32.0"
PACKAGE_SRC="https://busybox.net/downloads/busybox-1.32.0.tar.bz2"
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
	# we don't need init, as it would replace default openwrt init ELF!
	# still, just to be compliant, as this file does not exist:
	# echo '#!/bin/sh' > ${STAGING_DIR}/etc/init.d/rcS
	# chmod 755 ${STAGING_DIR}/etc/init.d/rcS

	mkdir -p ${STAGING_DIR}/bin

	#sleep 1
	#CC=${BUILD_CC} make CROSS_COMPILE=${BUILD_TARGET}- DESTDIR=${STAGING_DIR} install

	#cp -ar _install/* ${STAGING_DIR}

	echo "cp ${PACKAGE_SRC_DIR}/busybox ${STAGING_DIR}/bin/busybox"
	cp ${PACKAGE_SRC_DIR}/busybox ${STAGING_DIR}/bin/busybox
}

postinstall_package() {
	# delete unused init, will keep using the openwrt one
	rm -f ${STAGING_DIR}/sbin/init
}

