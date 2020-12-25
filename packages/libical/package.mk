PACKAGE_NAME="libical"
PACKAGE_VERSION="3.0.8"
PACKAGE_SRC="https://github.com/libical/libical/releases/download/v${PACKAGE_VERSION}/libical-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc glib libxml"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {
	#-DCMAKE_SYSROOT=${STAGING_DIR} \
	# CXXFLAGS="-I${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}/include ${BUILD_CFLAGS}" \
	#-D_GLIBCXX_USE_C99=ON \
	#-D_GLIBCXX_HAVE_WCSTOF=1 \

	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	cmake \
		-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
		-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_CMAKE} \
		-DENABLE_GTK_DOC=OFF \
		-DICAL_BUILD_DOCS=OFF \
		-DLIBICAL_BUILD_TESTING=OFF \
		${PACKAGE_SRC_DIR}
}

premake_package() {
	# FIXME this build is unstable, as it uses mixed libs from ARM and system.
	# Some commands used to fix this:

	echo_error "setting a horrible hack to fix the build"

	FILE_XLOCALE=${TOOLCHAIN_DIR}/${BUILD_TARGET}/libc/usr/include/xlocale.h
	FILE_LIBRESOLV=${TOOLCHAIN_DIR}/${BUILD_TARGET}/libc/lib/libresolv.so.2

	mv ${FILE_XLOCALE} ${FILE_XLOCALE}.bak
	ln -s ${STAGING_DIR}/usr/include/locale.h ${FILE_XLOCALE}

	mv ${FILE_LIBRESOLV} ${FILE_LIBRESOLV}.bak
	ln -s ${STAGING_DIR}/lib/libresolv.so.2 ${FILE_LIBRESOLV}
}


make_package() {
	make -j${MAKE_JOBS}
	EXITCODE=$?

	echo_info "undoing toolchain changes"

	rm ${FILE_XLOCALE}
	mv ${FILE_XLOCALE}.bak ${FILE_XLOCALE}

	rm ${FILE_LIBRESOLV}
	mv ${FILE_LIBRESOLV}.bak ${FILE_LIBRESOLV}

	return ${EXITCODE}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
