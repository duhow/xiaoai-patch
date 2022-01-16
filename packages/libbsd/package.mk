PACKAGE_NAME="libbsd"
PACKAGE_VERSION="0.10.0"
PACKAGE_SRC="https://github.com/freedesktop/libbsd/archive/refs/tags/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc"

preconfigure_package() {
	./autogen
}

configure_package() {
	# LDFLAGS="${BUILD_LDFLAGS}" 

	CC="${BUILD_CC}" CFLAGS="-Os" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
