PACKAGE_NAME="nqptp"
PACKAGE_VERSION="main" # 1.1-dev
PACKAGE_SRC="https://github.com/mikebrady/nqptp/archive/refs/heads/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc"

preconfigure_package() {
	autoreconf -fi
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="-I${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}/include --sysroot=${STAGING_DIR} ${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --sysconfdir=/etc --with-sysroot=${STAGING_DIR} \
		 --without-systemd-startup --without-freebsd-startup \
		 ac_cv_func_malloc_0_nonnull=yes \
		 ac_cv_func_realloc_0_nonnull=yes
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
