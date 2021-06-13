PACKAGE_NAME="libnpupnp"
PACKAGE_VERSION="4.1.4"
PACKAGE_SRC="https://www.lesbonscomptes.com/upmpdcli/downloads/libnpupnp-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc curl libmicrohttpd expat"

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="-I${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}/include --sysroot=${STAGING_DIR} ${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   PKG_CONFIG_PATH="${BUILD_PKG_CONFIG_LIBDIR}" \
	   ./configure --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --prefix="${STAGING_DIR}/${INSTALL_PREFIX}" \
	   --exec-prefix="${INSTALL_PREFIX}" \
	   --sysconfdir=/etc
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
