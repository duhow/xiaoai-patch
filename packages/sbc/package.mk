PACKAGE_NAME="Low Latency Subband Codec"
PACKAGE_VERSION="1.5"
# NOTE: v2.0 does not add important changes. Mirror repository is not updated.
PACKAGE_SRC="https://salsa.debian.org/bluetooth-team/sbc/-/archive/${PACKAGE_VERSION}/sbc-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc gcc libsndfile"

preconfigure_package() {
	autoreconf -fi
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
		 --enable-high-precision \
		 --disable-static --disable-tools --disable-tester
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
