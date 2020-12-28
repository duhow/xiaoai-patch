PACKAGE_NAME="minixml"
PACKAGE_VERSION="3.2"
PACKAGE_SRC="https://github.com/michaelrsweet/mxml/archive/v${PACKAGE_VERSION}.tar.gz"

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

postinstall_package() {
	PKGCONFIG_DIR="${STAGING_DIR}/usr/lib/pkgconfig"
	mkdir -p ${PKGCONFIG_DIR}
	cp mxml.pc ${PKGCONFIG_DIR}
}
