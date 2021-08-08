PACKAGE_NAME="curl"
PACKAGE_VERSION="7.78.0"
PACKAGE_SRC="https://github.com/curl/curl/releases/download/curl-${PACKAGE_VERSION//./_}/curl-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="zlib openssl nghttp2"

configure_package() {
	# --with-librtmp
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --with-ssl \
	   --with-zlib \
	   --with-nghttp2 \
	   --with-ca-bundle=/etc/ssl/certs/ca-cert.crt
	# remember to pass the target device's CA certs path
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	sed -i "s!libdir=.*!libdir='${STAGING_DIR}/${INSTALL_PREFIX}/lib'!" ${STAGING_DIR}/${INSTALL_PREFIX}/lib/libcurl.la
}
