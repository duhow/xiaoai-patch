PACKAGE_NAME="upmpdcli"
PACKAGE_VERSION="1.10.1"
PACKAGE_SRC="https://www.lesbonscomptes.com/upmpdcli/downloads/upmpdcli-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="libmpdclient libmicrohttpd jsoncpp libnpupnp libupnpp"

preconfigure_package() {
	sed -i "s|executable(|add_project_arguments('-I${STAGING_DIR}/${INSTALL_PREFIX}/include/libupnpp', language : 'cpp')\n\nexecutable(|g" meson.build
}

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
	mkdir -p ${STAGING_DIR}/etc/init.d ${STAGING_DIR}/etc/rc.d
	rm -rvf ${STAGING_DIR}/usr/share/upmpdcli/web
	rm -rvf ${STAGING_DIR}/usr/share/upmpdcli/cdplugins/*

	cp -vf ${PACKAGE_DIR}/config/icon.png ${STAGING_DIR}/${INSTALL_PREFIX}/share/upmpdcli
	cp -vf ${PACKAGE_DIR}/config/upmpdcli.conf ${STAGING_DIR}/etc/
	cp -vf ${PACKAGE_DIR}/config/upmpdcli.init ${STAGING_DIR}/etc/init.d/upmpdcli
	chmod 755 ${STAGING_DIR}/etc/init.d/upmpdcli
	ln -sf ../init.d/upmpdcli ${STAGING_DIR}/etc/rc.d/S98upmpdcli
}