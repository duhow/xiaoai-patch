PACKAGE_NAME="lc3"
PACKAGE_VERSION="1.1.1"
PACKAGE_SRC="https://github.com/google/liblc3/archive/refs/tags/v${PACKAGE_VERSION}.tar.gz"

make_package() {
	make -j${MAKE_JOBS} \
	  CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS} -fPIC -std=c11 -mfloat-abi=hard" \
		LDFLAGS="${BUILD_LDFLAGS} -nostartfiles -lm"
}

install_package() {
	cd ${PACKAGE_BUILD_DIR}
	cp -vf include/*.h ${STAGING_DIR}/usr/include/
	cp -v ${PACKAGE_DIR}/lc3.pc ${STAGING_DIR}/usr/lib/pkgconfig/
	cp -vf bin/liblc3.so ${STAGING_DIR}/usr/lib/
}
