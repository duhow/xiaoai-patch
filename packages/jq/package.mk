PACKAGE_NAME="jq"
PACKAGE_VERSION="1.6"
PACKAGE_SRC="https://github.com/stedolan/jq/releases/download/jq-${PACKAGE_VERSION}/jq-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="gcc"

preconfigure_package() {
	autoreconf -fi
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${STAGING_DIR}/${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --disable-valgrind --enable-shared --disable-static --disable-docs --with-oniguruma=builtin
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make install
}
