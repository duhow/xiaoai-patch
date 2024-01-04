PACKAGE_NAME="libopusenc"
PACKAGE_VERSION="0.2.1"
PACKAGE_SRC="https://github.com/xiph/libopusenc/archive/refs/tags/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="opus"

preconfigure_package() {
	echo "PACKAGE_VERSION=${PACKAGE_VERSION}" > ${PACKAGE_BUILD_DIR}/package_version
	autoreconf -fi
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   PKG_CONFIG_PATH="${BUILD_PKG_CONFIG_LIBDIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
