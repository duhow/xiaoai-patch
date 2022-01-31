PACKAGE_NAME="GNU C Library"
PACKAGE_VERSION="2.27"

[ "${BUILD_MODEL}" = "S12" ] && PACKAGE_VERSION="2.19"

PACKAGE_SRC="https://github.com/bminor/glibc/archive/refs/tags/glibc-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="toolchain kernel-headers"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {
	CC=${BUILD_CC} ${PACKAGE_SRC_DIR}/configure \
	   --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --target=${INSTALL_PREFIX} --with-target=${BUILD_ARCH} \
	   --with-fpu=vfp --with-float=hard \
	   --with-headers=${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}/include \
	   CFLAGS="${BUILD_CFLAGS}" --disable-werror
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
