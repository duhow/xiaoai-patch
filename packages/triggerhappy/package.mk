PACKAGE_NAME="Triggerhappy"
PACKAGE_VERSION="0.5.0"
PACKAGE_SRC="https://github.com/wertarbyte/triggerhappy/archive/release/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="base"

make_package() {
	CC=${BUILD_CC} CFLAGS=${BUILD_CFLAGS} LDFLAGS=${BUILD_LDFLAGS} \
	   make -j${MAKE_JOBS}
}

install_package() {
	TRIGGERHAPPY_FOLDER="${STAGING_DIR}/etc/triggerhappy/triggers.d"
	mkdir -p ${STAGING_DIR}/etc/init.d ${STAGING_DIR}/etc/rc.d
	mkdir -p ${TRIGGERHAPPY_FOLDER}
	cp -v thd th-cmd ${STAGING_DIR}/${INSTALL_PREFIX}/bin/

	cp -v ${PACKAGE_DIR}/config/triggerhappy.init ${STAGING_DIR}/etc/init.d/triggerhappy
	chmod 755 ${STAGING_DIR}/etc/init.d/triggerhappy
	ln -sf ../init.d/triggerhappy ${STAGING_DIR}/etc/rc.d/S70triggerhappy

	cp -v ${PACKAGE_DIR}/config/volume.conf ${TRIGGERHAPPY_FOLDER}
}
