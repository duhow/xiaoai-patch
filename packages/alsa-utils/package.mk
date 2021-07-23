PACKAGE_NAME="Advanced Linux Sound Architecture - Utils"
PACKAGE_VERSION="1.2.4"
PACKAGE_SRC="https://www.alsa-project.org/files/pub/utils/alsa-utils-${PACKAGE_VERSION}.tar.bz2"
PACKAGE_DEPENDS="ncurses"

configure_package() {
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	rm -vrf ${STAGING_DIR}/usr/share/sounds/alsa/Rear_*.wav
	rm -vrf ${STAGING_DIR}/usr/share/sounds/alsa/Side_*.wav
}
