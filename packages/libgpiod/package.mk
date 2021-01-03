PACKAGE_NAME="GPIO tools and lib"
PACKAGE_VERSION="1.6.2"
PACKAGE_SRC="https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc "

configure_package() {
	./autogen.sh \
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --enable-tools \
	   ac_cv_func_malloc_0_nonnull=yes \
	   ac_cv_func_realloc_0_nonnull=yes
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
