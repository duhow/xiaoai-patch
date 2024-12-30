PACKAGE_NAME="libevent"
PACKAGE_VERSION="2.1.12-stable"
PACKAGE_SRC="https://github.com/libevent/libevent/releases/download/release-${PACKAGE_VERSION}/libevent-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="openssl"

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --disable-doxygen-html --disable-debug-mode --disable-samples
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
  for FILE in event_rpcgen.py ; do
    rm -vf ${STAGING_DIR}/usr/bin/${FILE}
  done
}
