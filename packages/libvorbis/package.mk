PACKAGE_NAME="Libvorbis"
PACKAGE_VERSION="1.3.7"
PACKAGE_SRC="https://github.com/xiph/vorbis/releases/download/v${PACKAGE_VERSION}/libvorbis-${PACKAGE_VERSION}.tar.xz"
PACKAGE_DEPENDS="libogg"

configure_package() {
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" \
		 CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
		 LDFLAGS="${BUILD_LDFLAGS}" \
		 PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
		 PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
		 ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
		 --disable-static
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
