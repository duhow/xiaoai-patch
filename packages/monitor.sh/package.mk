PACKAGE_NAME="monitor.sh"
PACKAGE_VERSION="master" # 10b6cb7
PACKAGE_SRC="https://github.com/andrewjfreyer/monitor/archive/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="bash mosquitto bluez coreutils"

# requires stdbuf from coreutils

install_package() {
	cp -av ${PACKAGE_SRC_DIR} ${STAGING_DIR}/${INSTALL_PREFIX}/share/
	ln -sf ${INSTALL_PREFIX}/share/monitor.sh/monitor.sh ${STAGING_DIR}/${INSTALL_PREFIX}/bin/

	cp -v ${PACKAGE_DIR}/config/monitor.init ${STAGING_DIR}/etc/init.d/monitor_bluetooth
	ln -sf ../init.d/monitor_bluetooth ${STAGING_DIR}/etc/rc.d/S91monitor_bluetooth
}
