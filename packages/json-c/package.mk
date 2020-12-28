PACKAGE_NAME="json-c"
PACKAGE_VERSION="0.15-20200726"
PACKAGE_SRC="https://github.com/json-c/json-c/archive/json-c-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="gcc"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	cmake \
		-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
		-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_CMAKE} \
		-DBUILD_SHARED_LIBS=ON \
		${PACKAGE_SRC_DIR}
}

premake_package() {
	# FIXME this build is unstable, as it uses mixed libs from ARM and system.
	# Some commands used to fix this:

	echo_error "setting a horrible hack to fix the build"

	FILE_XLOCALE=${TOOLCHAIN_DIR}/${BUILD_TARGET}/libc/usr/include/xlocale.h

	mv ${FILE_XLOCALE} ${FILE_XLOCALE}.bak
	ln -s ${STAGING_DIR}/usr/include/locale.h ${FILE_XLOCALE}
}

make_package() {
	make -j${MAKE_JOBS}
	EXITCODE=$?

	echo_info "undoing toolchain changes"

	rm ${FILE_XLOCALE}
	mv ${FILE_XLOCALE}.bak ${FILE_XLOCALE}

	return ${EXITCODE}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
