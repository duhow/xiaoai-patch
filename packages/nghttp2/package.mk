PACKAGE_NAME="nghttp2"
PACKAGE_VERSION="1.42.0"
PACKAGE_SRC="https://github.com/nghttp2/nghttp2/releases/download/v${PACKAGE_VERSION}/nghttp2-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc gcc openssl zlib"

configure_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	cmake \
		-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_CMAKE} \
		-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
		${PACKAGE_SRC_DIR}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
