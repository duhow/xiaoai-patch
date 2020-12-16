PACKAGE_NAME="libmpdclient"
PACKAGE_VERSION="2.19"
PACKAGE_SRC="https://www.musicpd.org/download/libmpdclient/2/libmpdclient-2.19.tar.xz"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {

	in_to_out ${PACKAGE_DIR}/config/cross-file.build.in ./cross-file.build

	# Specify --libdir, or library files will be installed to ${INSTALL_PREFIX}/lib/${BUILD_TARGET} instead of ${INSTALL_PREFIX}/lib
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" meson --cross-file cross-file.build ${PACKAGE_SRC_DIR} output/release --buildtype=debugoptimized -Db_ndebug=true --prefix=${INSTALL_PREFIX} --libdir=${INSTALL_PREFIX}/lib
}

make_package() {
	ninja -C output/release
}

install_package() {
	DESTDIR=${STAGING_DIR} ninja -C output/release install
}