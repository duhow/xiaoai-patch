PACKAGE_NAME="libbsd"
PACKAGE_VERSION="0.10.0"
PACKAGE_SRC="https://github.com/guillemj/libbsd/archive/refs/tags/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc"

preconfigure_package() {
	if [ ! -f ".dist-version" ]; then
		echo -n "${PACKAGE_VERSION}" > .dist-version
	fi

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
