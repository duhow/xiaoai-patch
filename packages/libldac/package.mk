PACKAGE_NAME="LDAC Bluetooth Encoder"
PACKAGE_VERSION="2.0.2.3"
PACKAGE_SRC="https://github.com/EHfive/ldacBT/releases/download/v${PACKAGE_VERSION}/ldacBT-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	cmake \
		-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
		-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_CMAKE} \
		${PACKAGE_SRC_DIR}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
