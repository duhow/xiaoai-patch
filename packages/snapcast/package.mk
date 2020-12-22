PACKAGE_NAME="Snapcast"
PACKAGE_VERSION="v0.22.0"
PACKAGE_SRC="https://github.com/badaix/snapcast/archive/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="alsa libvorbis opus flac soxr avahi expat boost"

make_package() {
	make -j${MAKE_JOBS} \
	   CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PREFIX=${INSTALL_PREFIX}
}

install_package() {
	make DESTDIR=${STAGING_DIR} installserver installclient
}
