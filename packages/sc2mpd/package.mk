PACKAGE_NAME="sc2mpd"
PACKAGE_VERSION="1.1.7"
PACKAGE_SRC="https://www.lesbonscomptes.com/upmpdcli/downloads/sc2mpd-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc libmicrohttpd alsa-lib libsamplerate"

preconfigure_package() {
	FILE="openhome-sc2-20200704.tar.gz"
	if [ ! -e "${PACKAGE_SRC_DOWNLOAD_DIR}/${FILE}" ]; then
		echo_info "downloading openHome built package - ${FILE}"
                wget -O ${PACKAGE_SRC_DOWNLOAD_DIR}/${FILE} "https://www.lesbonscomptes.com/upmpdcli/downloads/${FILE}"
	fi
	echo_info "extracting openHome file"
	mkdir -p ${PACKAGE_SRC_DIR}/openhome
	tar -xf ${PACKAGE_SRC_DOWNLOAD_DIR}/${FILE} -C ${PACKAGE_SRC_DIR}/openhome
}

configure_package() {
	chmod +x ohbuild.sh
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="-I${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}/include --sysroot=${STAGING_DIR} ${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./ohbuild.sh ${PACKAGE_SRC_DIR}/openhome
}

premake_package() {
	./autogen.sh
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="-I${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}/include --sysroot=${STAGING_DIR} ${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --prefix=${INSTALL_PREFIX} --sysconfdir=/etc \
	   --with-openhome=${PACKAGE_SRC_DIR}/openhome
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
