PACKAGE_NAME="openaptX"
PACKAGE_VERSION="1.3.1"
PACKAGE_SRC="https://github.com/Arkq/openaptx/archive/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="libsndfile ffmpeg"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

preconfigure_package(){
	in_to_out ${PACKAGE_DIR}/cmake-toolchain.txt.in cmake-toolchain.txt
}

configure_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	cmake \
		-DCMAKE_TOOLCHAIN_FILE=cmake-toolchain.txt \
		-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
		-DWITH_FFMPEG=ON -DWITH_SNDFILE=ON \
		-DENABLE_APTX422=ON -DENABLE_APTXHD100=ON \
		${PACKAGE_SRC_DIR}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
