PACKAGE_NAME="nghttp2"
PACKAGE_VERSION="1.43.0"
PACKAGE_SRC="https://github.com/nghttp2/nghttp2/releases/download/v${PACKAGE_VERSION}/nghttp2-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc gcc openssl zlib"

configure_package() {
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" \
	   CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --disable-python-bindings --enable-lib-only
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	rm -rvf ${STAGING_DIR}/usr/share/nghttp2
}
