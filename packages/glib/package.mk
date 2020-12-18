PACKAGE_NAME="GLib"
PACKAGE_VERSION="2.67.0"
PACKAGE_DEPENDS="libffi"
PACKAGE_SRC="http://ftp.gnome.org/pub/gnome/sources/glib/2.67/glib-2.67.0.tar.xz"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {
	cat <<EOT > cross-file.build
[host_machine]
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

	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" meson --cross-file cross-file.build ${PACKAGE_SRC_DIR} output/release --buildtype=debugoptimized -Db_ndebug=true --prefix=${INSTALL_PREFIX} -Dlibmount=disabled
}

make_package() {
	ninja -C output/release
}

install_package() {
	DESTDIR=${STAGING_DIR} ninja -C output/release install
}