PACKAGE_NAME="libmpc"
PACKAGE_VERSION="0.1~r495"
PACKAGE_SRC="https://deb.debian.org/debian/pool/main/libm/libmpc/libmpc_0.1~r495.orig.tar.gz"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

# Original Musepack sources do not build properly (library files are not installed)
# We use source from Debian: https://packages.debian.org/bullseye/libmpcdec6
# along with its patches

#preconfigure_package() {
#	cd ${PACKAGE_SRC_DIR}
	# download and apply patches
#	wget -O patches.tar.xz http://deb.debian.org/debian/pool/main/libm/libmpc/libmpc_0.1~r495-2.debian.tar.xz
#	tar xf patches.tar.xz
#	patch -p1 < debian/patches/01_am-maintainer-mode.patch
#	patch -p1 < debian/patches/03_mpcchap.patch
#	patch -p1 < debian/patches/04_link-order.patch
#	patch -p1 < debian/patches/add_subdir-objects.patch
	#patch -p1 < debian/patches/05_visibility.patch
	#cd ${PACKAGE_BUILD_DIR}
#}

configure_package() {
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" cmake \
		-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_CMAKE} \
		-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
		-DCUEFILE_INCLUDE_DIR=${STAGING_DIR}/${INSTALL_PREFIX}/include \
		-DCUEFILE_LIBRARY=${STAGING_DIR}/${INSTALL_PREFIX}/lib/libcue.a \
		-DREPLAY_GAIN_INCLUDE_DIR=${STAGING_DIR}/${INSTALL_PREFIX}/include \
		${PACKAGE_SRC_DIR}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
