PACKAGE_NAME="Libgpg-error"
PACKAGE_VERSION="1.39"
PACKAGE_SRC="https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.39.tar.bz2"

preconfigure_package() {
	# allow building with gawk-5.0: http://www.linuxfromscratch.org/blfs/view/svn/general/libgpg-error.html
	sed -i 's/namespace/pkg_&/' src/Makefile.{am,in} src/mkstrtable.awk
}

configure_package() {
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}