PACKAGE_NAME="libupnpp"
PACKAGE_VERSION="1.0.4"
PACKAGE_SRC="https://www.lesbonscomptes.com/upmpdcli/downloads/libupnpp-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc libupnp libnpupnp curl expat"

configure_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
		meson setup --cross-file ${TOOLCHAIN_MESON} . build \
		--prefix=${INSTALL_PREFIX} \
		--sysconfdir=/etc \
		--libdir=${INSTALL_PREFIX}/lib
}

make_package() {
	ninja -C build
}

install_package() {
	DESTDIR=${STAGING_DIR} ninja -C build install
}

postinstall_package() {
	sed -i "s!prefix=.*!prefix=${INSTALL_PREFIX}!" ${STAGING_DIR}/${INSTALL_PREFIX}/lib/pkgconfig/libupnpp.pc
}