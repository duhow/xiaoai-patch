PACKAGE_NAME="Chromaprint"
PACKAGE_VERSION="1.5.0"
PACKAGE_SRC="https://github.com/acoustid/chromaprint/releases/download/v${PACKAGE_VERSION}/chromaprint-${PACKAGE_VERSION}.tar.gz"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	cmake \
		-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_SYSROOT_CMAKE} \
		-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
		${PACKAGE_SRC_DIR}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
