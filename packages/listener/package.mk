PACKAGE_NAME="listener"
PACKAGE_DEPENDS="openwakeword porcupine"

install_package() {
	mkdir -p ${STAGING_DIR}/etc/init.d ${STAGING_DIR}/etc/rc.d

	cp -v ${PACKAGE_DIR}/config/listener.init ${STAGING_DIR}/etc/init.d/listener
	ln -sf ../init.d/listener ${STAGING_DIR}/etc/rc.d/S98listener

	TRIGGERHAPPY_FOLDER="${STAGING_DIR}/etc/triggerhappy/triggers.d"
	mkdir -p ${TRIGGERHAPPY_FOLDER}

	cp -v ${PACKAGE_DIR}/config/triggerhappy.conf ${TRIGGERHAPPY_FOLDER}/listener.conf
	cp -v ${PACKAGE_DIR}/config/mic-aec.conf ${STAGING_DIR}/etc/alsa/conf.d/99-mic-aec.conf
}