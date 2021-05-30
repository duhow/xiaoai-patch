PACKAGE_NAME="Libcap"
PACKAGE_VERSION="2.48"
PACKAGE_SRC="https://git.kernel.org/pub/scm/linux/kernel/git/morgan/libcap.git/snapshot/libcap-${PACKAGE_VERSION}.tar.gz"

install_package() {
	# gperf breaks the build, so need BUILD_GPERF=no : https://www.mail-archive.com/lfs-dev@lists.linuxfromscratch.org/msg02782.html
	make install BUILD_GPERF=no DESTDIR=${STAGING_DIR} prefix=${INSTALL_PREFIX} CC="${BUILD_CC}" BUILD_CC=gcc CFLAGS="${BUILD_CFLAGS}" AR="${BUILD_AR}" RANLIB="${BUILD_RANLIB}" LDFLAGS="${BUILD_LDFLAGS}" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" RAISE_SETFCAP=no lib=lib
}
