PACKAGE_NAME="FAAD2"
PACKAGE_VERSION="2.11.1"
PACKAGE_SRC="https://github.com/knik0/faad2/archive/${PACKAGE_VERSION}.tar.gz"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	cmake \
		-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
		-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_CMAKE} \
		-DBUILD_SHARED_LIBS=ON \
		-DFAAD_BUILD_CLI=OFF \
		${PACKAGE_SRC_DIR}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
  rm -vf ${STAGING_DIR}/usr/bin/faad
}
