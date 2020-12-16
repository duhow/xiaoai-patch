PACKAGE_NAME="Linux kernel headers"
PACKAGE_VERSION="4.9.61"
PACKAGE_SRC="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.9.61.tar.xz"

install_package() {
	echo "mkdir -p ${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}"
	make ARCH=arm INSTALL_HDR_PATH=${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET} headers_install
}
