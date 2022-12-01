PACKAGE_NAME="BusyBox"
PACKAGE_VERSION="1.35.0"
PACKAGE_SRC="https://github.com/mirror/busybox/archive/refs/tags/${PACKAGE_VERSION//./_}.tar.gz"
PACKAGE_DEPENDS="base"

BUSYBOX_CONFIG=$(cat << EOF
LOCK=y
DPKG=n
DPKG_DEB=n
RPM=n
RPM2CPIO=n

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

LPD=n
LPR=n
LPQ=n

SENDMAIL=n
HUSH=n

EOF)
#FEATURE_PS_WIDE=y

configure_package() {
	CC=${BUILD_CC} make defconfig CROSS_COMPILE=${BUILD_TARGET}- CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" \
	     CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}"
}

premake_package() {
	echo "configuring additional functions"
	# https://busybox.net/FAQ.html#touch_config
	sleep 1

	for LINE in $(echo $BUSYBOX_CONFIG); do
		CFG_KEY=$(echo $LINE | cut -d '=' -f1)
		CFG_VAL=$(echo $LINE | cut -d '=' -f2)
		if [ -z "${CFG_KEY}" ] || [ -z "${CFG_VAL}" ]; then
		  continue
		fi
	  sed -i "/CONFIG_${CFG_KEY}=/c\\CONFIG_${CFG_KEY}=${CFG_VAL}" .config
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

