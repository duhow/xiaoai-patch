PACKAGE_NAME="libplist"
PACKAGE_VERSION="2.2.0"
# required to satisfy versioning error:
# configure: error: PACKAGE_VERSION is not defined. Make sure to configure a source tree checked out from git or that .tarball-version is present.
PACKAGE_SRC="https://github.com/libimobiledevice/libplist/releases/download/${PACKAGE_VERSION}/libplist-${PACKAGE_VERSION}.tar.bz2"
PACKAGE_DEPENDS="glib libxml gcc"

preconfigure_package() {
	autoreconf -fi
}

configure_package() {
	./configure CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS} -lm" \
	   CXX="${BUILD_CXX}" CXXFLAGS="-I${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}/include --sysroot=${STAGING_DIR} ${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --without-cython --disable-static --with-sysroot=${STAGING_DIR}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
  for FILE in plistutil ; do
    rm -vf ${STAGING_DIR}/usr/bin/${FILE}
  done
}
