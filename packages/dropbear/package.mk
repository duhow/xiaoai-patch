PACKAGE_NAME="Dropbear SSH"
PACKAGE_VERSION="2026.94"
PACKAGE_SRC="https://github.com/mkj/dropbear/archive/refs/tags/DROPBEAR_${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="base"

preconfigure_package() {
	sed -i 's/AC_PREREQ.*/AC_PREREQ([2.69])/' configure.ac
	autoreconf -vif
}

configure_package() {
	CC=${BUILD_CC} LDFLAGS="${BUILD_LDFLAGS}" ./configure \
		 --build=${MACHTYPE} --host=${BUILD_TARGET} --target=${BUILD_TARGET} --prefix=${INSTALL_PREFIX} \
		 --srcdir=src \
		 --disable-zlib
}

premake_package() {
	echo_notice "Patching config"
	sed -i 's!src/src!src!g' Makefile
	ln -sv ../libtommath src/libtommath
	ln -sv ../libtomcrypt src/libtomcrypt

	FILE_XLOCALE=${TOOLCHAIN_DIR}/${BUILD_TARGET}/libc/usr/include/xlocale.h
	mv ${FILE_XLOCALE} ${FILE_XLOCALE}.bak
	printf "typedef void *__locale_t;\ntypedef __locale_t locale_t;\n" > ${FILE_XLOCALE}
}

make_package() {
	CC=${BUILD_CC} LTM_CFLAGS="-Os" CFLAGS="-Os" make -j${MAKE_JOBS} \
		 PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" \
		 MULTI=1
	EXITCODE=$?

	rm ${FILE_XLOCALE}
	mv ${FILE_XLOCALE}.bak ${FILE_XLOCALE}

	return ${EXITCODE}
}

install_package() {
	cp -v ${PACKAGE_SRC_DIR}/dropbearmulti ${STAGING_DIR}/${INSTALL_PREFIX}/sbin/dropbear
}