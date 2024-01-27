PACKAGE_NAME="satellite"
PACKAGE_VERSION="1.1.0"
PACKAGE_SRC="https://github.com/rhasspy/wyoming-satellite/archive/v${PACKAGE_VERSION}.tar.gz"
PACAKGE_DEPENDS="python3 aec-cmdline"

make_package() {
	# TODO
}

install_package() {

	cp -v ${PACKAGE_DIR}/config/satellite.init ${STAGING_DIR}/etc/init.d/listener
	ln -sf ../init.d/listener ${STAGING_DIR}/etc/rc.d/S98listener

	TRIGGERHAPPY_FOLDER="${STAGING_DIR}/etc/triggerhappy/triggers.d"
	mkdir -p ${TRIGGERHAPPY_FOLDER}

	cp -v ${PACKAGE_DIR}/config/triggerhappy.conf ${TRIGGERHAPPY_FOLDER}/listener.conf
}
