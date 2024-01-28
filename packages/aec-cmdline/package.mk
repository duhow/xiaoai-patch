PACKAGE_NAME="aec_cmdline"
PACKAGE_VERSION="master"
PACKAGE_SRC="https://github.com/dr-ni/aec_cmdline/archive/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="alsa-lib speexdsp"

make_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS} -mfloat-abi=hard" \
	LDFLAGS="${BUILD_LDFLAGS} -ldl -lm -Wl,-Bstatic -Wl,-Bdynamic -lrt -lpthread -lasound -lspeexdsp" \
	make -j${MAKE_JOBS}
}

install_package() {
	cp -vf aec_cmdline ${STAGING_DIR}/usr/bin
}
