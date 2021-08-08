PACKAGE_NAME="libdaemon"
PACKAGE_VERSION="0.14"
PACKAGE_SRC="https://github.com/Distrotech/libdaemon/archive/refs/tags/v${PACKAGE_VERSION}.tar.gz"

configure_package() {
	# for autoconf flags, see: https://vanducuy.wordpress.com/2009/11/19/libdaemon-0-14-cross-compile-error/
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} ac_cv_func_getpgrp_void=no ac_cv_func_setpgrp_void=yes ac_cv_func_memcmp_working=yes rb_cv_binary_elf=no rb_cv_negative_time_t=no
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
