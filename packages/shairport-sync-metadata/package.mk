PACKAGE_NAME="shairport-sync-metadata-reader"
PACKAGE_VERSION="9caf251ecb91ab8a8825278bf804bd54425314b8"
PACKAGE_SRC="https://github.com/mikebrady/shairport-sync-metadata-reader/archive/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="shairport-sync"

preconfigure_package() {
	autoreconf -fi
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

