PACKAGE_NAME="libnl"
PACKAGE_VERSION="3.7.0"
PACKAGE_VERSION_TAG="$(echo "${PACKAGE_VERSION}" | tr . _)"
PACKAGE_SRC="https://github.com/thom311/libnl/releases/download/libnl${PACKAGE_VERSION_TAG}/libnl-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="base openssl"

configure_package(){
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --enable-cli=no --disable-debug --disable-static
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
