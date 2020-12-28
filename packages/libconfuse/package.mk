PACKAGE_NAME="libconfuse"
PACKAGE_VERSION="3.3"
PACKAGE_SRC="https://github.com/libconfuse/libconfuse/archive/v${PACKAGE_VERSION}.tar.gz"

preconfigure_package() {
	./autogen.sh
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --prefix=${INSTALL_PREFIX}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
