PACKAGE_NAME="openaptX"
PACKAGE_VERSION="1.2.0"
PACKAGE_SRC="https://github.com/Arkq/openaptx/archive/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="libsndfile ffmpeg"

preconfigure_package() {
	autoreconf --install
}

configure_package() {

	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS} -lm" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --with-sysroot=${STAGING_DIR} \
	   --with-ffmpeg --with-sndfile \
	   --enable-aptx422 --enable-aptxHD100 \
	   --disable-doc
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
