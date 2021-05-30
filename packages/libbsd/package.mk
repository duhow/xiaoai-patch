PACKAGE_NAME="libbsd"
PACKAGE_VERSION="0.11.3"
PACKAGE_SRC="https://libbsd.freedesktop.org/releases/libbsd-${PACKAGE_VERSION}.tar.xz"
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
