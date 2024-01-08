PACKAGE_NAME="OpusFile"
PACKAGE_VERSION="0.12"
PACKAGE_SRC="https://github.com/xiph/opusfile/archive/refs/tags/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="openssl opus libogg"

preconfigure_package() {
	./autogen.sh
	echo "PACKAGE_VERSION=${PACKAGE_VERSION}" > ${PACKAGE_BUILD_DIR}/package_version
}

configure_package() {
	OPUSDIR=${STAGING_DIR}/${INSTALL_PREFIX}/include/opus

	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	   PKG_CONFIG_PATH="${BUILD_PKG_CONFIG_LIBDIR}" \
	   DEPS_CFLAGS="-I${OPUSDIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --enable-fixed-point \
		 --disable-doc \
		 --disable-examples
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
