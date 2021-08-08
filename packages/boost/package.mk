PACKAGE_NAME="Boost C++ libraries"
PACKAGE_VERSION="1.76.0"
PACKAGE_SRC="https://github.com/boostorg/boost/archive/refs/tags/boost-${PACKAGE_VERSION}.tar.gz"

configure_package() {
	./bootstrap.sh
	wget https://raw.githubusercontent.com/powertechpreview/powertechpreview/master/Boost%20Patches/boost_1_70_cross.patch
	patch -p1 < boost_1_70_cross.patch
	echo "using gcc : arm : ${BUILD_CXX} : <compileflags>\"--sysroot=${STAGING_DIR} -I${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}/include ${BUILD_CFLAGS}\" <linkflags>\"--sysroot=${STAGING_DIR} ${BUILD_LDFLAGS}\"  ;" > ./tools/build/src/user-config.jam
}
	
install_package() {
	./b2 install toolset=gcc-arm \
		--architecture=arm \
		--without-python \
		--without-context \
		--variant=release \
		--prefix=${STAGING_DIR}/${INSTALL_PREFIX} \
		-j${MAKE_JOBS}
}

postinstall_package() {
	rm -rvf ${STAGING_DIR}/${INSTALL_PREFIX}/lib/libboost_*
}
