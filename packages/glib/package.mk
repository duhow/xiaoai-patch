PACKAGE_NAME="GLib"
PACKAGE_VERSION="2.67.0"
PACKAGE_SHORT_VERSION=${PACKAGE_VERSION::${#PACKAGE_VERSION}-2}
PACKAGE_DEPENDS="libffi zlib"
PACKAGE_SRC="https://download.gnome.org/sources/glib/${PACKAGE_SHORT_VERSION}/glib-${PACKAGE_VERSION}.tar.xz"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {
	cat <<EOT > cross-file.build
[host_machine]
system = 'linux'
cpu_family = 'arm'
cpu = 'any'
endian = 'little'

[target_machine]
system = 'linux'
cpu_family = 'arm'
cpu = 'any'
endian = 'little'

[properties]
c_args = '${BUILD_CFLAGS}'
c_link_args = '${BUILD_LDFLAGS}'
cpp_args = '${BUILD_CFLAGS}'
cpp_link_args = '${BUILD_LDFLAGS}'

[binaries]
c = '${BUILD_CC}'
cpp = '${BUILD_CXX}'
ar = '${BUILD_AR}'
objcopy = '${BUILD_OBJCOPY}'
strip = '${BUILD_STRIP}'
pkgconfig = '/usr/bin/pkg-config'
EOT

	#--buildtype=debugoptimized -Db_ndebug=true
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
		meson --cross-file cross-file.build ${PACKAGE_SRC_DIR} \
		_build \
		--prefix=${INSTALL_PREFIX} -Dlibmount=disabled -Dinstalled_tests=false
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
