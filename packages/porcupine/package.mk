PACKAGE_NAME="porcupine"
PACKAGE_VERSION="1.9"
PACKAGE_SRC="https://github.com/Picovoice/porcupine/archive/v${PACKAGE_VERSION}.tar.gz"
PACAKGE_DEPENDS="glibc alsa-lib"
PORCUPINE_FILE="demo/c/porcupine_demo_mic"

make_package() {
	echo ${BUILD_CC} -std=c99 -O3 ${BUILD_LDFLAGS} ${BUILD_CFLAGS} -ldl -lasound -o ${PORCUPINE_FILE} -I include/ ${PORCUPINE_FILE}.c
	${BUILD_CC} -std=c99 -O3 ${BUILD_LDFLAGS} ${BUILD_CFLAGS} -ldl -lasound -o ${PORCUPINE_FILE} -I include/ ${PORCUPINE_FILE}.c
}

install_package() {
	PORCUPINE_FOLDER="${STAGING_DIR}/${INSTALL_PREFIX}/share/porcupine"
	mkdir -p ${PORCUPINE_FOLDER}/keywords

	cp -v ${PORCUPINE_FILE} ${STAGING_DIR}/${INSTALL_PREFIX}/bin/porcupine
	cp -v ${PACKAGE_DIR}/config/launcher ${STAGING_DIR}/${INSTALL_PREFIX}/bin/porcupine_launcher

	chmod 755 ${STAGING_DIR}/${INSTALL_PREFIX}/bin/porcupine
	chmod 755 ${STAGING_DIR}/${INSTALL_PREFIX}/bin/porcupine_launcher

	cp -v lib/raspberry-pi/cortex-a7/libpv_porcupine.so ${STAGING_DIR}/${INSTALL_PREFIX}/lib/
	cp -v lib/common/porcupine_params.pv ${PORCUPINE_FOLDER}/model.pv
	cp -v resources/keyword_files/raspberry-pi/* ${PORCUPINE_FOLDER}/keywords/
}
