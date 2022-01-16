PACKAGE_NAME="OpenSSL"
PACKAGE_VERSION="1_1_1k"
PACKAGE_SRC="https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_${PACKAGE_VERSION}.tar.gz"

configure_package() {
	CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	./Configure linux-generic32 --prefix=${INSTALL_PREFIX} --cross-compile-prefix=${BUILD_TARGET}-
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install_sw install_ssldirs
}
