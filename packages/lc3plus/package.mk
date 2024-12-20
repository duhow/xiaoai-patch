PACKAGE_NAME="LC3plus"
PACKAGE_VERSION="1.5.1"
PACKAGE_COMMIT="97cad2ae4b7d4e323fda4787ad0a6dcb87daaeb6"
PACKAGE_SRC="https://github.com/arkq/${PACKAGE_NAME}/archive/${PACKAGE_COMMIT}.tar.gz"

VARIANT="floating_point" # floating_point or fixed_point

make_package() {
	# build dir
	cd src/${VARIANT}

	# this can make either the executable (LC3plus) or library (libLC3plus.so),
	# depending on the name called.

	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS} -mfloat-abi=hard" LDFLAGS="${BUILD_LDFLAGS}" \
	PREFIX=${INSTALL_PREFIX} VERBOSE=1 DEBUG=0 \
	make -j${MAKE_JOBS} libLC3plus.so
}

install_package() {
	cd ${PACKAGE_BUILD_DIR}/src/${VARIANT}

	if [ -f "libLC3plus.so" ]; then
		cp -vf libLC3plus.so ${STAGING_DIR}/usr/lib/
		cp -vf lc3plus.h ${STAGING_DIR}/usr/include/
	fi
	if [ -f "LC3plus" ]; then
		cp -vf LC3plus ${STAGING_DIR}/usr/bin/
	fi
}
