PACKAGE_NAME="libmpdclient"
PACKAGE_VERSION="2.20"
PACKAGE_SRC="https://github.com/MusicPlayerDaemon/libmpdclient/archive/refs/tags/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {
	# Specify --libdir, or library files will be installed to ${INSTALL_PREFIX}/lib/${BUILD_TARGET} instead of ${INSTALL_PREFIX}/lib
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	meson \
		--cross-file ${TOOLCHAIN_MESON} \
		${PACKAGE_SRC_DIR} output/release \
		--prefix=${INSTALL_PREFIX} \
		--libdir=${INSTALL_PREFIX}/lib
}

make_package() {
	ninja -C output/release
}

install_package() {
	DESTDIR=${STAGING_DIR} ninja -C output/release install
}
