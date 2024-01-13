PACKAGE_NAME="Advanced Linux Sound Architecture"
PACKAGE_VERSION="1.2.7"
PACKAGE_SRC="https://www.alsa-project.org/files/pub/lib/alsa-lib-${PACKAGE_VERSION}.tar.bz2"

configure_package() {
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET}
}

make_package() {
	make -j${MAKE_JOBS}
}

preinstall_package() {
	echo_warning "dirty patching libatopology.la to fix build"
	sed -i 's! /usr/lib/libasound.la ! !' ${PACKAGE_SRC_DIR}/src/topology/.libs/libatopology.lai
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
