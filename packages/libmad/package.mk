PACKAGE_NAME="MPEG Audio Decoder"
PACKAGE_VERSION="0.15.1b"
PACKAGE_SRC="https://downloads.sourceforge.net/mad/libmad-${PACKAGE_VERSION}.tar.gz"
# no longer updated

preconfigure_package(){
	# patches from https://www.linuxfromscratch.org/blfs/view/svn/multimedia/libmad.html
	touch NEWS AUTHORS ChangeLog
	sed "s@AM_CONFIG_HEADER@AC_CONFIG_HEADERS@g" -i configure.ac
	autoreconf -fi
}

configure_package() {
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" \
	   CFLAGS="${BUILD_CFLAGS} -marm" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   LDFLAGS="${BUILD_LDFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure \
	   --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --prefix=${INSTALL_PREFIX} \
	   --enable-fpm=arm --enable-shared --disable-static --disable-debugging
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
