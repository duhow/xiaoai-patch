PACKAGE_NAME="BusyBox"
PACKAGE_VERSION="1.36.1"
#PACKAGE_SRC="https://github.com/mirror/busybox/archive/refs/tags/${PACKAGE_VERSION//./_}.tar.gz"
PACKAGE_SRC="https://busybox.net/downloads/busybox-${PACKAGE_VERSION}.tar.bz2"
PACKAGE_DEPENDS="base"

BUSYBOX_CONFIG="
LOCK=y
DPKG=n
DPKG_DEB=n
RPM=n
RPM2CPIO=n
FEATURE_PS_WIDE=y
FEATURE_PS_LONG=y

ACPID=n
EJECT=n
FBSET=n
LSPCI=n
LSUSB=n
MKSWAP=n
SWAPON=n
SWAPOFF=n
LSSCSI=n

WGET=n
WHOIS=n
TRACEROUTE=n
TRACEROUTE6=n

ADDGROUP=n
ADDUSER=n
DELUSER=n
DELGROUP=n
SULOGIN=n
FSCK=n
BLKID=n
FDISK=n
FSCK_MINIX=n
MKFS_MINIX=n
HDPARM=n
MAN=n
TFTPD=n
FTPD=n
FTPGET=n
FTPPUT=n

LPD=n
LPR=n
LPQ=n

SENDMAIL=n
HUSH=n
"

configure_package() {
	CC=${BUILD_CC} make defconfig CROSS_COMPILE=${BUILD_TARGET}- CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" \
	     CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}"
}

premake_package() {
	echo_info "configuring additional functions"
	# https://busybox.net/FAQ.html#touch_config
	sleep 1

	echo "${BUSYBOX_CONFIG}" | while read -r LINE; do
		CFG_KEY=$(echo $LINE | cut -d '=' -f1)
		CFG_VAL=$(echo $LINE | cut -d '=' -f2)
		if [ -z "${CFG_KEY}" ] || [ -z "${CFG_VAL}" ]; then
		  continue
		fi

		CONFIG_LINE="CONFIG_${CFG_KEY}=${CFG_VAL}"
	  sed -i "/CONFIG_${CFG_KEY}=/c\\${CONFIG_LINE}" .config
		if ! grep -q "${CONFIG_LINE}" .config; then
			echo ${CONFIG_LINE} >> .config
		fi
	done
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
		patch realpath sha1sum sha256sum sha3sum sha512sum stat tac tftp tftpd unix2dos xxd \
		kill w watch; do
		ln -vsf busybox ${STAGING_DIR}/bin/${NAME}
	done

	for NAME in pkill pgrep pmap free top uptime; do
		ln -vsf /bin/busybox ${STAGING_DIR}/usr/bin/${NAME}
	done
}

