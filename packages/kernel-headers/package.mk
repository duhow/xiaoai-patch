PACKAGE_NAME="Linux kernel headers"
PACKAGE_VERSION="4.9.61" # LX06

[ "${BUILD_MODEL}" = "LX01" ] && PACKAGE_VERSION="3.4.39"
[ "${BUILD_MODEL}" = "S12" ] && PACKAGE_VERSION="3.14.29"

PACKAGE_SRC="https://cdn.kernel.org/pub/linux/kernel/v${PACKAGE_VERSION:0:1}.x/linux-${PACKAGE_VERSION}.tar.xz"

install_package() {
	echo "mkdir -p ${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}"
	local kernel_arch
	case ${BUILD_ARCH} in
		"arm"|"armv7")
		kernel_arch="arm"
		;;
		"aarch64")
		kernel_arch="arm64"
		;;
		*)
		echo_error "Error: Unknown target '${BUILD_ARCH}'. Toolchain setup failed."
		return 1
		;;
	esac

	make ARCH=${kernel_arch} INSTALL_HDR_PATH=${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET} headers_install
	#make ARCH=${kernel_arch} CROSS_COMPILE=${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}- modules
	#make ARCH=${kernel_arch} CROSS_COMPILE=${TOOLCHAIN_DIR}/bin/${BUILD_TARGET}- modules_install
}
