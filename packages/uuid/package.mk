PACKAGE_NAME="libuuid"
PACKAGE_VERSION="2.38.1"
PACKAGE_VERSION_SHORT=${PACKAGE_VERSION::${#PACKAGE_VERSION}-2}
PACKAGE_SRC="https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v${PACKAGE_VERSION_SHORT}/util-linux-${PACKAGE_VERSION}.tar.xz"
PACKAGE_DEPENDS="glibc"

preconfigure_package() {
	autoreconf -fi
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="-I${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}/include --sysroot=${STAGING_DIR} ${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --sysconfdir=/etc --with-sysroot=${STAGING_DIR} \
		 --disable-all-programs --disable-libblkid --disable-libmount \
		 --disable-libsmartcols --disable-libfdisk \
		 --without-systemd --without-python \
		 --enable-libuuid --enable-libuuid-force-uuidd
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
