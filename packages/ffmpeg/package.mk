PACKAGE_NAME="FFmpeg"
PACKAGE_VERSION="4.3.1"
PACKAGE_SRC="https://www.ffmpeg.org/releases/ffmpeg-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="openssl"

configure_package() {
	export PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}"
	export PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}"
	# compile with -fpic flag, otherwise the soxr package will fail to build
	./configure \
		--prefix=${INSTALL_PREFIX} \
		--arch=${BUILD_TARGET} \
		--target-os=linux \
		--cross-prefix=${BUILD_TARGET}- \
		--cc="${BUILD_CC} -fPIC" \
		--cxx="${BUILD_CXX}" \
		--extra-cflags="${BUILD_CFLAGS} -w" \
		--extra-ldflags="${BUILD_LDFLAGS}" \
		--pkg-config="/usr/bin/pkg-config" \
		--enable-openssl
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
