PACKAGE_NAME="vorbis-tools"
PACKAGE_VERSION="1.4.2"
PACKAGE_SRC="https://github.com/xiph/vorbis-tools/archive/refs/tags/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc libogg libvorbis libao curl flac speex opusfile"

preconfigure_package() {
	mv vorbis-tools-master/* .
	./autogen.sh
}

configure_package() {
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" \
	   CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
		 --disable-static \
		 --disable-oggenc --disable-ogginfo --disable-oggtest \
		 --disable-vcut --disable-vorbiscomment \
		 --disable-vorbistest --disable-curltest
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
