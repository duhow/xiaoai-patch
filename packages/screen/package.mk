PACKAGE_NAME="screen"
PACKAGE_VERSION="4.9.0"
PACKAGE_SRC="https://ftp.gnu.org/gnu/screen/screen-${PACKAGE_VERSION}.tar.gz"

preconfigure_package() {
	./autogen.sh
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --with-sysroot=${STAGING_DIR}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
