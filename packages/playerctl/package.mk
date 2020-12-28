PACKAGE_NAME="playerctl"
PACKAGE_VERSION="2.3.1"
PACKAGE_SRC="https://github.com/altdesktop/playerctl/archive/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc glib"

configure_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
		meson --cross-file ${TOOLCHAIN_MESON} \
		${PACKAGE_SRC_DIR} output/release \
		-Dgtk-doc=false -Dintrospection=false \
		--prefix=${INSTALL_PREFIX}
}

make_package() {
	ninja -C output/release
}

install_package() {
	DESTDIR=${STAGING_DIR} ninja -C output/release install
}
