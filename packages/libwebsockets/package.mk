PACKAGE_NAME="libwebsockets"
PACKAGE_VERSION="4.1.6"
PACKAGE_SRC="https://github.com/warmcat/libwebsockets/archive/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glib openssl"
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

postinstall_package() {
	rm -rvf ${STAGING_DIR}/${INSTALL_PREFIX}/share/libwebsockets-test-server
	rm -rvf ${STAGING_DIR}/${INSTALL_PREFIX}/bin/libwebsockets-test*
}
