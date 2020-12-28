PACKAGE_NAME="wget2"
PACKAGE_VERSION="latest"
PACKAGE_SRC="https://gnuwget.gitlab.io/wget2/wget2-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc zlib bzip2 nghttp2 pcre openssl"


configure_package() {
	# disabling microhttpd, only used for tests and will crash build if gnutls is not provided

	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --disable-static --disable-doc --disable-manylibs \
	   --with-ssl=openssl --with-openssl --without-gnutls \
	   --enable-threads=posix --without-libmicrohttpd
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	ln -s wget2 ${STAGING_DIR}/usr/bin/wget
	rm ${STAGING_DIR}/usr/bin/wget2_noinstall
}
