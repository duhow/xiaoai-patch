PACKAGE_NAME="syslog-ng"
PACKAGE_VERSION="3.31.2"
PACKAGE_SRC="https://github.com/syslog-ng/syslog-ng/releases/download/syslog-ng-${PACKAGE_VERSION}/syslog-ng-${PACKAGE_VERSION}.tar.gz"
# NOTE: packed release contains gitmodules which are REQUIRED. git tag DOES NOT contain them.
PACKAGE_DEPENDS="json-c pcre openssl"

preconfigure_package() {
	autoreconf -fi
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="-DSQLITE_ENABLE_UNLOCK_NOTIFY ${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --enable-ipv6 \
		 --disable-python \
		 --disable-java \
		 --disable-manpages-install \
		 --disable-all-modules \
		 --enable-static \
		 --disable-shared \
		 --without-compile-date \
		 --with-systemd-journal=optional
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
