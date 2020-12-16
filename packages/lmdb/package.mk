PACKAGE_NAME="Lightning Memory-Mapped Database"
PACKAGE_VERSION="0.9.24"
PACKAGE_SRC="https://github.com/LMDB/lmdb/archive/LMDB_0.9.24.tar.gz"

make_package() {
	cd libraries/liblmdb
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" PREFIX="${INSTALL_PREFIX}" make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}