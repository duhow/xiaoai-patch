PACKAGE_NAME="hey-wifi"
PACKAGE_VERSION="main"
PACKAGE_SRC="https://github.com/duhow/hey-wifi-c/archive/main.tar.gz"
PACKAGE_DEPENDS="alsa-lib quiet"

make_package() {
	make CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS} ${BUILD_LDFLAGS} -lm"
}

install_package() {
	HEYWIFI_FOLDER=${STAGING_DIR}/usr/share/hey-wifi
	mkdir -p ${HEYWIFI_FOLDER}
	cp -vf hey-wifi ${STAGING_DIR}/usr/bin
	cp -vf *.json ${HEYWIFI_FOLDER}
	cp -vf ${PACKAGE_DIR}/config/heywifi.init ${STAGING_DIR}/etc/init.d/heywifi
}
