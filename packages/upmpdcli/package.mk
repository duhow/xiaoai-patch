PACKAGE_NAME="upmpdcli"
PACKAGE_VERSION="1.5.7"
#PACKAGE_SRC="https://www.lesbonscomptes.com/upmpdcli/downloads/upmpdcli-${PACKAGE_VERSION}.tar.gz"
PACKAGE_SRC="https://framagit.org/medoc92/upmpdcli/-/archive/master/upmpdcli-master.tar.gz"
PACKAGE_DEPENDS="libmpdclient libmicrohttpd jsoncpp libnpupnp libupnpp" # sc2mpd

preconfigure_package() {
	./autogen.sh
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="-I${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}/include --sysroot=${STAGING_DIR} ${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --prefix=${INSTALL_PREFIX} --sysconfdir=/etc

}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	mkdir -p ${STAGING_DIR}/etc/init.d ${STAGING_DIR}/etc/rc.d

	cp -vf ${PACKAGE_DIR}/config/upmpdcli.conf ${STAGING_DIR}/etc/
	cp ${PACKAGE_DIR}/config/upmpdcli.init ${STAGING_DIR}/etc/init.d/upmpdcli
	chmod 755 ${STAGING_DIR}/etc/init.d/upmpdcli
	ln -sf ../init.d/upmpdcli ${STAGING_DIR}/etc/rc.d/S98upmpdcli
}
