PACKAGE_NAME="Linux kernel headers"
PACKAGE_VERSION="4.9.61"
PACKAGE_SRC="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.9.61.tar.xz"

install_package() {
	echo "mkdir -p ${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}"
    local kernel_arch
    case ${BUILD_ARCH} in
	"arm"|"armv7")
        kernel_arch="arm"
        ;;
    "x86")
        kernel_arch="x86"
        ;;
    *)
		echo_error "Error: Unknown target '${BUILD_ARCH}'. Toolchain setup failed."
		return 1
		;;
	esac

	make ARCH=${kernel_arch} INSTALL_HDR_PATH=${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET} headers_install
}
