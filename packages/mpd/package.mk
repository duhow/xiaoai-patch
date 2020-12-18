PACKAGE_NAME="MPD"
PACKAGE_VERSION="0.22.2"
PACKAGE_DEPENDS="base support system multimedia"
PACKAGE_SRC="http://www.musicpd.org/download/mpd/0.22/mpd-0.22.2.tar.xz"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

preconfigure_package() {
	# add install_rpath so meson will set rpath of mpd executable
	local install_rpath="\'${INSTALL_PREFIX}/${BUILD_TARGET}/lib:${INSTALL_PREFIX}/lib\'"
	sed -i -e "s/mpd = build_target(/install_rpath = ${install_rpath//\//\\\/}\n\nmpd = build_target(/g" \
		-e "s/install: not is_android and not is_haiku,/install: not is_android and not is_haiku,\n install_rpath: install_rpath,/g" \
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
