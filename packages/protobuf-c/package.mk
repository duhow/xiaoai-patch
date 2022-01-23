PACKAGE_NAME="protobuf-c"
PACKAGE_VERSION="1.4.0"
PACKAGE_SRC="https://github.com/protobuf-c/protobuf-c/archive/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="protobuf"

preconfigure_package() {
	./autogen.sh
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="-I${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}/include --sysroot=${STAGING_DIR} ${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --with-sysroot=${STAGING_DIR} PROTOC=${STAGING_DIR}/${INSTALL_PREFIX}/bin/protoc
}

premake_package() {
        # FIXME this build is unstable, as it uses mixed libs from ARM and system.
        # Some commands used to fix this:

        echo_warning "setting a horrible hack to fix the build"

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

	# rm -vf ${STAGING_DIR}/${INSTALL_PREFIX}/lib/libprotobuf.so*
}
