PACKAGE_NAME="openaptX"
PACKAGE_VERSION="0.2.1"
PACKAGE_SRC="https://github.com/pali/libopenaptx/archive/refs/tags/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="libsndfile ffmpeg"

make_package() {
	CC="${BUILD_CC}" CFLAGS="-Os" \
	PREFIX=${INSTALL_PREFIX} \
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} PREFIX=${INSTALL_PREFIX} install
}
