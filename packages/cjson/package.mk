PACKAGE_NAME="cJSON"
PACKAGE_VERSION="v1.7.14"
PACKAGE_SRC="https://github.com/DaveGamble/cJSON/archive/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

preconfigure_package() {
	# remove setting, otherwise can't build
	sed -i '/-pedantic/d' ${PACKAGE_SRC_DIR}/CMakeLists.txt
}

configure_package() {
	LDFLAGS="-lm" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
		cmake \
		-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_CMAKE} \
		-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
		${PACKAGE_SRC_DIR} 
}

make_package() {
	CC=${BUILD_CC} make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
