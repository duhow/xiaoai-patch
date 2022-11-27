PACKAGE_NAME="jsoncpp"
PACKAGE_VERSION="1.9.5"
PACKAGE_SRC="https://github.com/open-source-parsers/jsoncpp/archive/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	meson \
		--buildtype release \
		--default-library shared \
		--cross-file ${TOOLCHAIN_MESON} \
		--prefix=${INSTALL_PREFIX} \
		${PACKAGE_SRC_DIR} \
		output/release
}

make_package() {
	ninja -C output/release
}

install_package() {
	DESTDIR=${STAGING_DIR} ninja -C output/release install
}
