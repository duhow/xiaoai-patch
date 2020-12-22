PACKAGE_NAME="Linux Infrared Remote Control"
PACKAGE_VERSION="0.10.1"
#PACKAGE_VERSION="0.9.4d"
PACKAGE_SRC="https://sourceforge.net/projects/lirc/files/LIRC/${PACKAGE_VERSION}/lirc-${PACKAGE_VERSION}.tar.bz2"
PACKAGE_DEPENDS="glibc gcc alsa-lib"

#preconfigure_package() {
#	./autogen.sh
#}

configure_package() {
	#CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET}
	#CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS} -Wl,--rpath-link=/usr/include/python3.8 "
	#CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS} -I/usr/include/python3.8" LDFLAGS="${BUILD_LDFLAGS}"

	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --with-systemdsystemunitdir=no HAVE_WORKING_POLL=no SYSTEMD_INSTALL=no PYTHON=no
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
