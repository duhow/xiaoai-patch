PACKAGE_NAME="libxml"
PACKAGE_VERSION="2.12.3"
PACKAGE_SRC="https://github.com/GNOME/libxml2/archive/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc zlib"

configure_package() {
	./autogen.sh CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --with-minimum --without-python \
		 --without-catalog \
		 --without-history \
     --without-debug \
	   --with-zlib \
	   --with-sysroot=${STAGING_DIR}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
  for FILE in xmllint xmlcatalog ; do
		rm -rvf ${STAGING_DIR}/usr/bin/${FILE}
	done
}
