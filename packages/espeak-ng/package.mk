PACKAGE_NAME="espeak-ng"
PACKAGE_VERSION="1.50"
PACKAGE_SRC="https://github.com/espeak-ng/espeak-ng/releases/download/${PACKAGE_VERSION}/espeak-ng-${PACKAGE_VERSION}.tgz"
PACKAGE_DEPENDS="base glibc"

preconfigure_package() {
	./autogen.sh
}

configure_package() {
	CFLAGS="-Os" ./configure --with-speechplayer=no --with-sonic=no
}

premake_package() {
	# build voice data local
	make -j${MAKE_JOBS} src/espeak-ng src/speak-ng
	make
}

make_package() {
	CC=${BUILD_CC} CFLAGS=${BUILD_CFLAGS} ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
		 --with-speechplayer=no --with-sonic=no

	make -B src/espeak-ng src/speak-ng
}

install_package() {
	mkdir -p ${STAGING_DIR}/${INSTALL_PREFIX}/share ${STAGING_DIR}/${INSTALL_PREFIX}/bin
	cp -ra ${PACKAGE_SRC_DIR}/espeak-ng-data ${STAGING_DIR}/${INSTALL_PREFIX}/share/espeak-ng-data
	cp ${PACKAGE_SRC_DIR}/src/speak-ng ${STAGING_DIR}/${INSTALL_PREFIX}/bin
	[ -e ${STAGING_DIR}/${INSTALL_PREFIX}/bin/espeak ] || ln -s speak-ng ${STAGING_DIR}/${INSTALL_PREFIX}/bin/espeak
}
