PACKAGE_NAME="Libgcrypt"
PACKAGE_VERSION="1.10.1"
PACKAGE_DEPENDS="libgpg-error"
PACKAGE_SRC="https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-${PACKAGE_VERSION}.tar.bz2"


configure_package() {
	# LX01 and S12 do not support the getentropy function (kernel version too low).
	# This affects shairport-sync AirPlay2 feature, issue #97
	EXTRA_FLAGS=""
	if [ "$BUILD_MODEL" = "LX01" ] || [ "$BUILD_MODEL" = "S12" ]; then
	    EXTRA_FLAGS="--enable-random=linux"
	fi
	
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" \
		 CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
		 PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
		 ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
		 --with-libgpg-error-prefix=${STAGING_DIR}/${INSTALL_PREFIX} \
		 ${EXTRA_FLAGS}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
  for FILE in dumpsexp mpicalc ; do
    rm -vf ${STAGING_DIR}/usr/bin/${FILE}
  done
}
