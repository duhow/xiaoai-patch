PACKAGE_NAME="AdPlug - AdLib sound player library"
PACKAGE_VERSION="2.3.3"
PACKAGE_DEPENDS="libbinio"
PACKAGE_SRC="https://github.com/adplug/adplug/releases/download/adplug-2.3.3/adplug-2.3.3.tar.bz2"

preconfigure_package() {
	# The configure script looks for <sys/io.h> and sets the HAVE_SYS_IO_H flag.
    # In glibc 2.30 the <sys/io.h> header file has been removed for 32-bit ARM arch.
    # Since the toolchain is using an older verion of glibc, the configure script still detects the existence
    # of the header file and compiles on this basis. The result would be a library with missing references
	# when linked against the newer version of glibc. So we would have to prevent the configure script
	# from setting the HAVE_SYS_IO_H flag.
	if [[ ${BUILD_ARCH} == "armv7" ]]; then
		sed -i 's/#define HAVE_SYS_IO_H 1//g' ./configure
	fi
}

configure_package() {
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}