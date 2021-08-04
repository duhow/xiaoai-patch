PACKAGE_NAME="forked-daapd"
PACKAGE_VERSION="27.2"
PACKAGE_SRC="https://github.com/owntone/owntone-server/archive/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc zlib sqlite3 alsa-lib avahi curl ffmpeg libevent libconfuse libunistring json-c minixml libwebsockets libgcrypt libplist libsodium libantlr3c"

preconfigure_package() {
	autoreconf -fi
	# ./scripts/antlr35_install.sh -p /usr/local -y
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS} -lm" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   PKG_CONFIG_PATH="${BUILD_PKG_CONFIG_LIBDIR}" \
	   ./configure --build=${MACHTYPE} --host=${BUILD_TARGET} --target=${BUILD_TARGET} \
	   --prefix=${INSTALL_PREFIX} --with-sysroot=${STAGING_DIR} \
	   --sysconfdir=/etc \
	   --localstatedir=/var \
	   --enable-itunes --enable-lastfm --disable-chromecast \
	   --disable-webinterface --enable-mpd \
	   --with-libplist --with-libwebsockets --with-alsa \
	   --without-pulseaudio
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	rm -rvf ${STAGING_DIR}/${INSTALL_PREFIX}/share/forked-daapd/htdocs/admin/vendor/fontawesome/webfonts/*.svg
}
