PACKAGE_NAME="mosquitto"
PACKAGE_VERSION="2.0.5"
PACKAGE_SRC="https://mosquitto.org/files/source/mosquitto-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="base glibc cjson"

preconfigure_package() {
	sed -i "/prefix?/c prefix?=${INSTALL_PREFIX}" config.mk
}

make_package() {
	# openssl disabled temporally
	LDFLAGS="-L${STAGING_DIR}/usr/lib -Wl,--rpath-link=${STAGING_DIR}/lib -Os" CFLAGS=${BUILD_CFLAGS} \
					make -j${MAKE_JOBS} CC=${BUILD_CC} CXX=${BUILD_CXX} WITH_DOCS=no WITH_TLS=no
 
}

install_package() {
	LDFLAGS="-L${STAGING_DIR}/usr/lib -Wl,--rpath-link=${STAGING_DIR}/lib -Os" CFLAGS=${BUILD_CFLAGS} make DESTDIR=${STAGING_DIR} install CC=${BUILD_CC} WITH_DOCS=no WITH_TLS=no
	echo ""
}
