PACKAGE_NAME="gobject-introspection"
PACKAGE_VERSION="1.68.0"
PACKAGE_SRC="https://github.com/GNOME/gobject-introspection/archive/refs/tags/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc glib libffi python3"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	PKG_CONFIG_PATH="${BUILD_PKG_CONFIG_LIBDIR}" \
		meson --cross-file ${TOOLCHAIN_MESON} \
		${PACKAGE_SRC_DIR} output/release \
		-Dbuild_introspection_data=true \
		-Denable-host-gi=true \
		--prefix=${INSTALL_PREFIX}
}

make_package() {
	ninja -C output/release
}

install_package() {
	DESTDIR=${STAGING_DIR} ninja -C output/release install
}
