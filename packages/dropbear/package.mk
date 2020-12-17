PACKAGE_NAME="Dropbear SSH"
PACKAGE_VERSION="2020.81"
PACKAGE_SRC="https://mirror.dropbear.nl/mirror/releases/dropbear-${PACKAGE_VERSION}.tar.bz2"
PACKAGE_DEPENDS="base"

configure_package() {
	# package depend zlib may be added later
	CC=${BUILD_CC} ./configure CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" --prefix=${INSTALL_PREFIX} --disable-zlib
}

make_package() {
	CC=${BUILD_CC} make -j${MAKE_JOBS} \
		 PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" \
		 MULTI=1
}

install_package() {
	echo "cp ${PACKAGE_SRC_DIR}/dropbearmulti ${STAGING_DIR}/${INSTALL_PREFIX}/sbin/dropbear"
	cp ${PACKAGE_SRC_DIR}/dropbearmulti ${STAGING_DIR}/${INSTALL_PREFIX}/sbin/dropbear
}
