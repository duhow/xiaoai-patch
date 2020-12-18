PACKAGE_NAME="Boost C++ libraries"
PACKAGE_VERSION="1.74.0"
PACKAGE_SRC="https://dl.bintray.com/boostorg/release/1.74.0/source/boost_1_74_0.tar.gz"

configure_package() {
	./bootstrap.sh
	wget https://raw.githubusercontent.com/powertechpreview/powertechpreview/master/Boost%20Patches/boost_1_70_cross.patch
	patch -p1 < boost_1_70_cross.patch
	echo "using gcc : arm : ${BUILD_CXX} : <compileflags>\"${BUILD_CFLAGS}\" <linkflags>\"${BUILD_LDFLAGS}\" ;" > ./tools/build/src/user-config.jam
}
	
install_package() {
	./b2 install toolset=gcc-arm --without-python --prefix=${STAGING_DIR}/${INSTALL_PREFIX} --debug-configuration -j8
}