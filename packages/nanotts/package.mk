PACKAGE_NAME="nanotts"
PACKAGE_VERSION="master"
PACKAGE_SRC="https://github.com/gmn/nanotts/archive/refs/heads/master.tar.gz"
PACKAGE_DEPENDS="alsa-lib"

configure_package(){
	cd svoxpico
	./autogen.sh

	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	    ./configure --host `uname -m`

	make -j2
	cd ..
}
make_package() {
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" \
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	make nanotts CFLAGS="${BUILD_LDFLAGS} ${BUILD_CFLAGS}"
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
	rm -rvf ${STAGING_DIR}/usr/local/include/pico*.h
}
