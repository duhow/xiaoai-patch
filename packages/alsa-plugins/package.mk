PACKAGE_NAME="Advanced Linux Sound Architecture - Plugins"
PACKAGE_VERSION="1.2.7.1"
PACKAGE_SRC="https://www.alsa-project.org/files/pub/plugins/alsa-plugins-${PACKAGE_VERSION}.tar.bz2"
PACKAGE_DEPENDS="alsa-lib"

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --with-sysroot="${STAGING_DIR}" \
	   --disable-pulseaudio --disable-jack --disable-arcamav --disable-oss
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
