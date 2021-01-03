PACKAGE_NAME="Noise Suppression for Voice - RNNoise"
PACKAGE_VERSION="0.91"
PACKAGE_SRC="https://github.com/werman/noise-suppression-for-voice/archive/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="alsa-lib"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	cmake \
		-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
		-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_SYSROOT_CMAKE} \
		-DCMAKE_BUILD_TYPE=Release \
		-DBUILD_VST_PLUGIN=OFF \
		-DBUILD_LV2_PLUGIN=OFF \
		-DBUILD_LADSPA_PLUGIN=ON \
		${PACKAGE_SRC_DIR}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
