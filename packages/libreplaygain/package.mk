PACKAGE_NAME="libreplaygain"
PACKAGE_VERSION="r475"
PACKAGE_SRC="https://files.musepack.net/source/libreplaygain_r475.tar.gz"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" cmake -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_CMAKE} -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} ${PACKAGE_SRC_DIR}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	# 'make install' doesn't copy include headers, so we would have to do it manually
	cp -a ${PACKAGE_SRC_DIR}/include/replaygain ${STAGING_DIR}/${INSTALL_PREFIX}/include
}