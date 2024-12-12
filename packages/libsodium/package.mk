PACKAGE_NAME="libsodium"
PACKAGE_VERSION="1.0.20"
PACKAGE_SRC="https://github.com/jedisct1/libsodium/archive/refs/tags/${PACKAGE_VERSION}-RELEASE.tar.gz"

preconfigure_package() {
  autoreconf -fi
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS} -lm" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
