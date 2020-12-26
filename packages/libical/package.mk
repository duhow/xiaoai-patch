PACKAGE_NAME="libical"
PACKAGE_VERSION="3.0.8"
PACKAGE_SRC="https://github.com/libical/libical/releases/download/v${PACKAGE_VERSION}/libical-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc glib libxml"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

preconfigure_package() {
	in_to_out ${PACKAGE_DIR}/cmake-toolchain.txt.in ${PACKAGE_SRC_DIR}/cmake-toolchain.txt
}

configure_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	cmake \
		-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
		-DCMAKE_TOOLCHAIN_FILE=${PACKAGE_SRC_DIR}/cmake-toolchain.txt \
		-DENABLE_GTK_DOC=OFF \
		-DICAL_BUILD_DOCS=OFF \
		-DICAL_GLIB=False \
		-DLIBICAL_BUILD_TESTING=OFF \
		${PACKAGE_SRC_DIR}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
