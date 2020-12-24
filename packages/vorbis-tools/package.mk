PACKAGE_NAME="vorbis-tools"
PACKAGE_VERSION="1.4.0-master"
PACKAGE_SRC="https://github.com/xiph/vorbis-tools/archive/master.zip"
PACKAGE_DEPENDS="glibc libogg libvorbis libao curl flac speex"

preconfigure_package() {
	mv vorbis-tools-master/* .
	./autogen.sh
}

configure_package() {
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" \
	   CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
