PACKAGE_NAME="getevent"
PACKAGE_VERSION="master"
PACKAGE_SRC="https://github.com/WangZhaosong/getevent/archive/refs/heads/master.tar.gz"
PACKAGE_DEPENDS=""

preconfigure_package() {
	cp -vf ${PACKAGE_DIR}/input.h-labels.h ${PACKAGE_SRC_DIR}
}

make_package() {
	${BUILD_CC} ${BUILD_CFLAGS} -o ${PACKAGE_NAME} getevent.c
}

install_package() {
	install -v ${PACKAGE_NAME} ${STAGING_DIR}/${INSTALL_PREFIX}/bin/
}
