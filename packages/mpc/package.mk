PACKAGE_NAME="mpc"
PACKAGE_VERSION="0.34"
PACKAGE_SRC="https://github.com/MusicPlayerDaemon/mpc/archive/refs/tags/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc libmpdclient"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

preconfigure_package() {
	# add install_rpath so meson will set rpath of mpc executable
	local install_rpath="\'${INSTALL_PREFIX}/${BUILD_TARGET}/lib:${INSTALL_PREFIX}/lib\'"
	sed -i -e "s/executable('mpc',/install_rpath = ${install_rpath//\//\\\/}\n\nexecutable('mpc',/g" \
		-e "s/install: true/install: true,\n install_rpath: install_rpath/g" \
		${PACKAGE_SRC_DIR}/meson.build
	
}

configure_package() {
	# Specify --libdir, or library files will be installed to ${INSTALL_PREFIX}/lib/${BUILD_TARGET} instead of ${INSTALL_PREFIX}/lib
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	meson \
		--cross-file ${TOOLCHAIN_MESON} \
		${PACKAGE_SRC_DIR} \
		output/release \
		--prefix=${INSTALL_PREFIX}
}

make_package() {
	ninja -C output/release
}

install_package() {
	DESTDIR=${STAGING_DIR} ninja -C output/release install
}

postinstall_package() {
	TRIGGERHAPPY_FOLDER="${STAGING_DIR}/etc/triggerhappy/triggers.d"
	mkdir -p ${TRIGGERHAPPY_FOLDER}

	cp -v ${PACKAGE_DIR}/config/triggerhappy.conf ${TRIGGERHAPPY_FOLDER}/mpc.conf

	rm -rvf ${STAGING_DIR}/usr/share/vala
}
