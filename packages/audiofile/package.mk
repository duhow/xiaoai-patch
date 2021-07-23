PACKAGE_NAME="AudioFile"
PACKAGE_VERSION="0.3.6"
PACKAGE_SRC="https://github.com/mpruett/audiofile/archive/refs/tags/audiofile-${PACKAGE_VERSION}.tar.gz"

configure_package() {
	# add -std=c++98 flag to CXXFLAGS: http://www.linuxfromscratch.org/blfs/view/svn/multimedia/audiofile.html
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="-std=c++98 ${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
