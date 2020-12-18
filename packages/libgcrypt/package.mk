PACKAGE_NAME="Libgcrypt"
PACKAGE_VERSION="1.8.7"
PACKAGE_DEPENDS="libgpg-error"
PACKAGE_SRC="https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.8.7.tar.bz2"


configure_package() {
	if [[ "${BUILD_ARCH}" == "x86" ]]; then
		local extra_flags="--disable-asm"
	fi

	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} --with-libgpg-error-prefix=${STAGING_DIR}/${INSTALL_PREFIX} ${extra_flags}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}