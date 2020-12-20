PACKAGE_NAME="Triggerhappy"
PACKAGE_VERSION="0.5.0"
PACKAGE_SRC="https://github.com/wertarbyte/triggerhappy/archive/release/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="base"

make_package() {
	CC=${BUILD_CC} CFLAGS=${BUILD_CFLAGS} LDFLAGS=${BUILD_LDFLAGS} \
	   make -j${MAKE_JOBS}
}

install_package() {
	echo "cp ${PACKAGE_SRC_DIR}/thd ${STAGING_DIR}/${INSTALL_PREFIX}/bin/thd"
	cp ${PACKAGE_SRC_DIR}/thd ${STAGING_DIR}/${INSTALL_PREFIX}/bin/thd
}
