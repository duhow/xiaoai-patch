PACKAGE_NAME="mpc"
PACKAGE_VERSION="0.33"
PACKAGE_DEPENDS="mpd"
PACKAGE_SRC="http://www.musicpd.org/download/mpc/0/mpc-0.33.tar.xz"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

preconfigure_package() {
	# add install_rpath so meson will set rpath of mpc executable
	local install_rpath="\'${INSTALL_PREFIX}/${BUILD_TARGET}/lib:${INSTALL_PREFIX}/lib\'"
	sed -i -e "s/executable('mpc',/install_rpath = ${install_rpath//\//\\\/}\n\nexecutable('mpc',/g" \
		-e "s/install: true/install: true,\n install_rpath: install_rpath/g" \
		${PACKAGE_SRC_DIR}/meson.build
	
}

configure_package() {

	in_to_out ${PACKAGE_DIR}/config/cross-file.build.in ./cross-file.build

	# Specify --libdir, or library files will be installed to ${INSTALL_PREFIX}/lib/${BUILD_TARGET} instead of ${INSTALL_PREFIX}/lib
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" meson --cross-file cross-file.build ${PACKAGE_SRC_DIR} output/release --buildtype=debugoptimized -Db_ndebug=true --prefix=${INSTALL_PREFIX}
}

make_package() {
	ninja -C output/release
}

install_package() {
	DESTDIR=${STAGING_DIR} ninja -C output/release install
}
