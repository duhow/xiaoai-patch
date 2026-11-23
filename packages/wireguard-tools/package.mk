PACKAGE_NAME="wireguard-tools"
PACKAGE_VERSION="1.0.20260223"
PACKAGE_SRC="https://git.zx2c4.com/wireguard-tools/snapshot/wireguard-tools-v${PACKAGE_VERSION}.tar.xz"
PACKAGE_DEPENDS="glibc"

premake_package() {
	mkdir -p "${STAGING_DIR}${INSTALL_PREFIX}/include/linux"
	cp -vf src/uapi/linux/linux/wireguard.h "${STAGING_DIR}${INSTALL_PREFIX}/include/linux/wireguard.h"
}

make_package() {
	make -C src -j${MAKE_JOBS} \
		CC="${BUILD_CC} -DRUNSTATEDIR='\"/var/run\"'" \
		CFLAGS="${BUILD_CFLAGS}" \
		LDFLAGS="${BUILD_LDFLAGS}"
}

install_package() {
	make -C src \
		DESTDIR="${STAGING_DIR}" \
		PREFIX="${INSTALL_PREFIX}" \
		WITH_BASHCOMPLETION=no \
		WITH_SYSTEMDUNITS=no \
		WITH_WGQUICK=yes \
		install
}