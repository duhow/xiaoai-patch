PACKAGE_NAME="Bluetooth Audio ALSA Backend"
PACKAGE_VERSION="3.0.0"
PACKAGE_SRC="https://github.com/Arkq/bluez-alsa/archive/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="alsa-lib bluez sbc mpg123 lame libldac openaptx dbus glib"

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --enable-mp3lame \
	   --enable-mpg123 \
	   --enable-ldac
	   #--enable-aptx --enable-aptx-hd
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
