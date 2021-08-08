PACKAGE_NAME="Dropbear SSH"
PACKAGE_VERSION="2020.81"
PACKAGE_SRC="https://github.com/mkj/dropbear/archive/refs/tags/DROPBEAR_${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="base"

configure_package() {
	# package depend zlib may be added later
	#--with-zlib=${STAGING_DIR}/${INSTALL_PREFIX}/lib

	CC=${BUILD_CC} LDFLAGS="${BUILD_LDFLAGS}" ./configure \
		 --build=${MACHTYPE} --host=${BUILD_TARGET} --target=${BUILD_TARGET} --prefix=${INSTALL_PREFIX} \
		 --disable-zlib
}

make_package() {
	CC=${BUILD_CC} CFLAGS="-Os" make -j${MAKE_JOBS} \
		 PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" \
		 MULTI=1
}

install_package() {
	echo "cp ${PACKAGE_SRC_DIR}/dropbearmulti ${STAGING_DIR}/${INSTALL_PREFIX}/sbin/dropbear"
	cp ${PACKAGE_SRC_DIR}/dropbearmulti ${STAGING_DIR}/${INSTALL_PREFIX}/sbin/dropbear
}
