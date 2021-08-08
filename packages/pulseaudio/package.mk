PACKAGE_NAME="PulseAudio"
PACKAGE_VERSION="13.99.2"
PACKAGE_SRC="https://github.com/freedesktop/pulseaudio/archive/refs/tags/v${PACKAGE_VERSION}.tar.gz"

configure_package() {
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} --with-udev-rules-dir=${INSTALL_PREFIX}/lib/udev/rules.d
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
