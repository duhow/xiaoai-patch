PACKAGE_NAME="bzip2"
PACKAGE_VERSION="1.0.8"
PACKAGE_SRC="https://www.sourceware.org/pub/bzip2/bzip2-${PACKAGE_VERSION}.tar.gz"

install_package() {
	make CC="${BUILD_CC} -fPIC" AR="${BUILD_TARGET}-ar" RANLIB="${BUILD_TARGET}-ranlib" LDFLAGS="${BUILD_LDFLAGS}" libbz2.a bzip2 bzip2recover
	make PREFIX=${STAGING_DIR}/${INSTALL_PREFIX} install
	make clean
	make -f Makefile-libbz2_so CC="${BUILD_CC}" AR="${BUILD_TARGET}-ar" RANLIB="${BUILD_TARGET}-ranlib" LDFLAGS="${BUILD_LDFLAGS}"
	cp -av libbz2.so* ${STAGING_DIR}/${INSTALL_PREFIX}/lib
}

postinstall_package() {
	in_to_out ${PACKAGE_DIR}/config/bzip2.pc.in ${STAGING_DIR}/${INSTALL_PREFIX}/lib/pkgconfig/bzip2.pc
	# fix broken symlinks
	ln -sf bzdiff ${STAGING_DIR}/${INSTALL_PREFIX}/bin/bzcmp
	ln -sf bzgrep ${STAGING_DIR}/${INSTALL_PREFIX}/bin/bzegrep
	ln -sf bzgrep ${STAGING_DIR}/${INSTALL_PREFIX}/bin/bzfgrep
	ln -sf bzmore ${STAGING_DIR}/${INSTALL_PREFIX}/bin/bzless
}
