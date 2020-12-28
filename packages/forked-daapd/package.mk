PACKAGE_NAME="forked-daapd"
PACKAGE_VERSION="27.2"
PACKAGE_SRC="https://github.com/ejurgensen/forked-daapd/archive/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc zlib sqlite3 alsa-lib avahi curl ffmpeg libevent libconfuse libunistring json-c minixml libwebsockets gnutls libplist libsodium protobuf-c"

preconfigure_package() {
	./scripts/antlr35_install.sh -p /usr/local -y && autoreconf -i
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   PKG_CONFIG_PATH="${BUILD_PKG_CONFIG_LIBDIR}" \
	   ./configure --build=${MACHTYPE} --host=${BUILD_TARGET} --target=${BUILD_TARGET} \
	   --prefix=${INSTALL_PREFIX} \
	   --sysconfdir=/etc \
	   --localstatedir=/var \
	   --enable-itunes --enable-lastfm --enable-chromecast \
	   --enable-webinterface --enable-mpd \
	   --with-libplist --with-libwebsockets --with-alsa \
	   --without-pulseaudio
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
