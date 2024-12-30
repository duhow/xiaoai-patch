PACKAGE_NAME="Free Lossless Audio Codec"
PACKAGE_VERSION="1.4.3"
PACKAGE_SRC="https://github.com/xiph/flac/archive/refs/tags/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="libogg gcc"

preconfigure_package() {
	mv flac-master/* .
	./autogen.sh
}

configure_package() {
	# disable libFLAC++ temporally, having some error when building
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" \
	   CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --disable-cpplibs --disable-doxygen-docs --disable-oggtest --disable-programs --disable-examples
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
