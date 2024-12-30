PACKAGE_NAME="mpg123"
PACKAGE_VERSION="1.32.4"
PACKAGE_SRC="https://sourceforge.net/projects/mpg123/files/mpg123/${PACKAGE_VERSION}/mpg123-${PACKAGE_VERSION}.tar.bz2"
PACKAGE_DEPENDS="alsa-lib"

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
		 --disable-components \
		 --enable-programs \
		 --enable-libmpg123 \
		 --enable-libout123 \
		 --enable-libout123-modules \
		 --with-audio=alsa
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
  for FILE in out123 mpg123-id3dump mpg123-strip ; do
    rm -vf ${STAGING_DIR}/usr/bin/${FILE}
  done
}
