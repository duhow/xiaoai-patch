PACKAGE_NAME="GnuTLS"
PACKAGE_VERSION="3.7.2"
PACKAGE_VERSION_SHORT=${PACKAGE_VERSION::${#PACKAGE_VERSION}-2}
PACKAGE_SRC="https://www.gnupg.org/ftp/gcrypt/gnutls/v${PACKAGE_VERSION_SHORT}/gnutls-${PACKAGE_VERSION}.tar.xz"
PACKAGE_DEPENDS="gmp p11-kit nettle"

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="-I${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}/include --sysroot=${STAGING_DIR} ${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} --with-included-unistring
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
