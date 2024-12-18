PACKAGE_NAME="Dropbear SSH"
PACKAGE_VERSION="2024.86"
PACKAGE_SRC="https://github.com/mkj/dropbear/archive/refs/tags/DROPBEAR_${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="base"

preconfigure_package() {
	autoreconf -vif
}

configure_package() {
	# package depend zlib may be added later
	#--with-zlib=${STAGING_DIR}/${INSTALL_PREFIX}/lib

	CC=${BUILD_CC} LDFLAGS="${BUILD_LDFLAGS}" ./configure \
		 --build=${MACHTYPE} --host=${BUILD_TARGET} --target=${BUILD_TARGET} --prefix=${INSTALL_PREFIX} \
		 --srcdir=src \
		 --disable-zlib
}

premake_package() {
  echo_notice "Patching config"
	sed -i 's!src/src!src!g' Makefile
	ln -sv ../libtommath src/libtommath
	ln -sv ../libtomcrypt src/libtomcrypt
}

make_package() {
	CC=${BUILD_CC} LTM_CFLAGS="${BUILD_CFLAGS}" CFLAGS="-Os" make -j${MAKE_JOBS} \
		 PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" \
		 MULTI=1
}

install_package() {
	echo "cp ${PACKAGE_SRC_DIR}/dropbearmulti ${STAGING_DIR}/${INSTALL_PREFIX}/sbin/dropbear"
	cp ${PACKAGE_SRC_DIR}/dropbearmulti ${STAGING_DIR}/${INSTALL_PREFIX}/sbin/dropbear
}
