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

make_package() {
	# FIXME NOTE this build is unstable, as it uses mixed libs from ARM and system.
	# Some commands used to fix this:

	# mv ./build-packages/build/armv7/toolchain/arm-linux-gnueabihf/libc/usr/include/xlocale.h{,.bak}
	# rm build-packages/build/armv7/toolchain/arm-linux-gnueabihf/libc/lib/libresolv.so.2
	# ln -s $PWD/build-packages/staging/armv7/lib/libresolv.so.2 build-packages/build/armv7/toolchain/arm-linux-gnueabihf/libc/lib/libresolv.so.2

	ninja -k 0 -C _build
}

install_package() {
	DESTDIR=${STAGING_DIR} ninja -C _build install
}
