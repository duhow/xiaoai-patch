PACKAGE_NAME="BusyBox"
PACKAGE_VERSION="1.32.0"
PACKAGE_SRC="https://busybox.net/downloads/busybox-1.32.0.tar.bz2"
PACKAGE_DEPENDS="base"

preconfigure_package() {
  echo "Downloading OpenWRT to apply busybox patches"
	wget https://github.com/openwrt/openwrt/archive/master.zip
	unzip master.zip
	CUR=$PWD
	for FILE in openwrt-master/package/utils/busybox/patches/*; do 
	  echo "applying patch $FILE"
		patch --batch --reverse -p1 < $FILE
	done
	rm -rf openwrt-master master.zip
}

configure_package() {
	CC=${BUILD_CC} make defconfig CROSS_COMPILE=${BUILD_TARGET}- CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" \
	     CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
			 CONFIG_PREFIX=${STAGING_DIR} \
			 CONFIG_LOCK=y
	sed -i '/CONFIG_LOCK is not/c\CONFIG_LOCK=y' .config
}

make_package() {
	CC=${BUILD_CC} make -j${MAKE_JOBS} CROSS_COMPILE=${BUILD_TARGET}-
}

install_package() {
	CC=${BUILD_CC} make CROSS_COMPILE=${BUILD_TARGET}- DESTDIR=${STAGING_DIR} install
	#cp -ar _install/* ${STAGING_DIR}
}
