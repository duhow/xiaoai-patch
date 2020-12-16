PACKAGE_NAME="BusyBox"
PACKAGE_VERSION="1.32.0"
PACKAGE_SRC="https://busybox.net/downloads/busybox-1.32.0.tar.bz2"
PACKAGE_DEPENDS="base"

configure_package() {
	CC=${BUILD_CC} make defconfig CROSS_COMPILE=${BUILD_TARGET}- CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" \
	     CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}"
}

make_package() {
	CC=${BUILD_CC} make -j${MAKE_JOBS} CROSS_COMPILE=${BUILD_TARGET}-
}

install_package() {
	CC=${BUILD_CC} make CROSS_COMPILE=${BUILD_TARGET}- DESTDIR=${STAGING_DIR} install
	cp -ar _install/* ${STAGING_DIR}
}
