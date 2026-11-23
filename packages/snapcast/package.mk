PACKAGE_NAME="Snapcast"
PACKAGE_VERSION="0.30.0"
PACKAGE_SRC="https://github.com/badaix/snapcast/archive/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="alsa-lib libvorbis opus flac soxr avahi expat boost"
BUILD_TARGETS="server client"

if [ "${BUILD_MODEL}" = "LX01" ]; then
	BUILD_TARGETS="client"
fi

preconfigure_package() {
	# Фикс для GCC 7.4.1: переводим filesystem на experimental/filesystem
	grep -rl "filesystem" common/ server/ client/ | xargs -r sed -i 's|<filesystem>|<experimental/filesystem>|g; s|std::filesystem|std::experimental::filesystem|g'
}

configure_package() {
	OPT_SERVER="OFF"
	OPT_CLIENT="OFF"
	[[ "${BUILD_TARGETS}" = *"server"* ]] && OPT_SERVER="ON"
	[[ "${BUILD_TARGETS}" = *"client"* ]] && OPT_CLIENT="ON"

	mkdir -p build && cd build
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	PKG_CONFIG_PATH="${BUILD_PKG_CONFIG_LIBDIR}" \
	cmake .. \
	   -DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_DIR}/config/cmake-toolchain-sysroot.txt" \
	   -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
	   -DCMAKE_CXX_STANDARD_LIBRARIES="-lstdc++fs -latomic" \
	   -DBUILD_SERVER=${OPT_SERVER} \
	   -DBUILD_CLIENT=${OPT_CLIENT} \
	   -DBUILD_WITH_PULSE=OFF \
	   -DBUILD_TESTS=OFF
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install/strip
}

postinstall_package() {
	mkdir -p ${STAGING_DIR}/etc/init.d ${STAGING_DIR}/etc/rc.d

	for NAME in ${BUILD_TARGETS}; do
		cp -v ${PACKAGE_DIR}/config/snap${NAME}.init ${STAGING_DIR}/etc/init.d/snap${NAME}
		chmod 755 ${STAGING_DIR}/etc/init.d/snap${NAME}
	done
	ln -sf ../init.d/snapclient ${STAGING_DIR}/etc/rc.d/S95snapclient

	if [[ "${BUILD_TARGETS}" = *"server"* ]]; then
		mkdir -p ${STAGING_DIR}/${INSTALL_PREFIX}/share/snapserver/snapweb
		cp -v ${PACKAGE_DIR}/config/snapserver.conf ${STAGING_DIR}/etc/snapserver.conf
		cp -rvf ../server/etc/snapweb ${STAGING_DIR}/${INSTALL_PREFIX}/share/snapserver/
	fi
}
