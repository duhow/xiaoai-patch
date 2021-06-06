PACKAGE_NAME="Quiet"
PACKAGE_VERSION="master"
PACKAGE_SRC="https://github.com/quiet/quiet/archive/master.tar.gz"
PACKAGE_DEPENDS="glibc liquid-dsp libfec jansson libsndfile"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

preconfigure_package() {
	in_to_out ${PACKAGE_DIR}/cmake-toolchain.txt.in cmake-toolchain.txt
}

configure_package() {
	LD_LIBRARY_PATH=${STAGING_DIR}/${INSTALL_PREFIX} \
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	cmake \
		-DCMAKE_TOOLCHAIN_FILE=cmake-toolchain.txt \
		-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
		${PACKAGE_SRC_DIR}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
        rm -rvf ${STAGING_DIR}/usr/share/quiet
}
