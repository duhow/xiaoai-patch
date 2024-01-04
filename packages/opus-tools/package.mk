PACKAGE_NAME="Opus-tools"
PACKAGE_VERSION="0.2-next"
PACKAGE_SRC="https://github.com/xiph/opus-tools/archive/ecd50e531fbf378499a3f71cdca05ad969c2e29f.tar.gz"
PACKAGE_DEPENDS="opus libopusenc"

preconfigure_package() {
	autoreconf -fi && \
	echo "PACKAGE_VERSION=${PACKAGE_VERSION}" > ${PACKAGE_BUILD_DIR}/package_version
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   PKG_CONFIG_PATH="${BUILD_PKG_CONFIG_LIBDIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
		 --disable-oggtest \
		 --disable-opustest \
		 --disable-opusfiletest \
		 --disable-libopusenctest \
		 --without-libopusenc \
		 --without-flac
}

make_package() {
	make -j${MAKE_JOBS} && exit 1
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
