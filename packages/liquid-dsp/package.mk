PACKAGE_NAME="liquid-dsp-quiet"
PACKAGE_VERSION="devel"
#PACKAGE_SRC="https://github.com/jgaeddert/liquid-dsp/archive/master.tar.gz"
PACKAGE_SRC="https://github.com/quiet/quiet-dsp/archive/devel.tar.gz"
PACKAGE_DEPENDS="libfec"

preconfigure_package() {
	./bootstrap.sh
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   ac_cv_func_malloc_0_nonnull=yes \
	   ac_cv_func_realloc_0_nonnull=yes
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
