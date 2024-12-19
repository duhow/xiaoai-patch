PACKAGE_NAME="GLib"
PACKAGE_VERSION="2.68.2"
PACKAGE_SRC="https://github.com/GNOME/glib/archive/refs/tags/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="libffi zlib"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
		meson setup --cross-file ${TOOLCHAIN_MESON} ${PACKAGE_SRC_DIR} \
		_build \
		--prefix=${INSTALL_PREFIX} -Dlibmount=disabled -Dinstalled_tests=false
}

premake_package() {
	# FIXME this build is unstable, as it uses mixed libs from ARM and system.
	# Some commands used to fix this:

	echo_warning "setting a horrible hack to fix the build"

	FILE_XLOCALE=${TOOLCHAIN_DIR}/${BUILD_TARGET}/libc/usr/include/xlocale.h
	FILE_LIBRESOLV=${TOOLCHAIN_DIR}/${BUILD_TARGET}/libc/lib/libresolv.so.2

	mv ${FILE_XLOCALE} ${FILE_XLOCALE}.bak
	ln -s ${STAGING_DIR}/usr/include/locale.h ${FILE_XLOCALE}

	mv ${FILE_LIBRESOLV} ${FILE_LIBRESOLV}.bak
	ln -s ${STAGING_DIR}/lib/libresolv.so.2 ${FILE_LIBRESOLV}
}

make_package() {
	ninja -k 0 -C _build
	EXITCODE=$?

	echo_info "undoing toolchain changes"

	rm ${FILE_XLOCALE}
	mv ${FILE_XLOCALE}.bak ${FILE_XLOCALE}

	rm ${FILE_LIBRESOLV}
	mv ${FILE_LIBRESOLV}.bak ${FILE_LIBRESOLV}

	return ${EXITCODE}
}

install_package() {
	DESTDIR=${STAGING_DIR} ninja -C _build install
}

postinstall_package() {
	rm -rvf ${STAGING_DIR}/usr/share/gdb
	rm -rvf ${STAGING_DIR}/usr/share/glib-2.0/codegen

	# /usr/share/gdb/auto-load/usr/lib/libgobject-2.0.so.0.6702.0-gdb.py
}
