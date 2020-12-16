PACKAGE_NAME="Systemd"
PACKAGE_DEPENDS="attr libcap kmod"
PACKAGE_SRC="https://github.com/systemd/systemd/archive/v215.tar.gz"

preconfigure_package() {
	# include <sys/sysmacros.h> header in src/shared/util.h (in our glibc version, major/minor...macros have been moved to sysmacros.h)
	# include <stdint.h> header in src/udev/mtd_probe/mtd_probe.h 
 	# disable ld.gold
	./autogen.sh
	sed -i "/#include <sys\/types.h>/a #include <sys\/sysmacros.h>" src/shared/util.h
	sed -i "/#include <mtd\/mtd-user.h>/a #include <stdint.h>" src/udev/mtd_probe/mtd_probe.h
	sed -i 's/-Wl,-fuse-ld=gold//g' ./configure ./Makefile.in
}

configure_package() {
	# fool configure test with 'ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes' (ref: https://github.com/openvenues/libpostal/issues/134)
	LT_SYS_LIBRARY_PATH="${STAGING_DIR}/${INSTALL_PREFIX}/lib" CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes ./configure --prefix=${INSTALL_PREFIX} --with-rootprefix=${INSTALL_PREFIX} --with-sysvinit-path=${INSTALL_PREFIX}/etc/init.d --with-sysvrcnd-path=${INSTALL_PREFIX}/etc/rc.d --with-rc-local-script-path-start=${INSTALL_PREFIX}/etc/rc.local --build=${MACHTYPE} --host=${BUILD_TARGET} 
}

make_package() {
	LT_SYS_LIBRARY_PATH="${STAGING_DIR}/${INSTALL_PREFIX}/lib" make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}