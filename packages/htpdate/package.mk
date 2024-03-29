PACKAGE_NAME="htpdate"
PACKAGE_VERSION="1.3.7"
PACKAGE_SRC="https://github.com/angeloc/htpdate/archive/refs/tags/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="openssl"

make_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	make ENABLE_HTTPS=1
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
