PACKAGE_NAME="Snapcast"
PACKAGE_VERSION="0.27.0"
PACKAGE_SRC="https://github.com/badaix/snapcast/archive/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="alsa libvorbis opus flac soxr avahi expat"
BOOST_VERSION="1.84.0"
BOOST="boost_${BOOST_VERSION//./_}"
BUILD_TARGETS="server client"

if [ "${BUILD_MODEL}" = "LX01" ]; then
BUILD_TARGETS="client"
fi

prepare_boost() {
	BOOST_PKG="${PACKAGE_SRC_DOWNLOAD_DIR}/../boost/${BOOST}.tar.gz"
	BOOST_SRC="https://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION}/${BOOST}.tar.gz/download"
	if [ ! -e "${BOOST_PKG}" ]; then
			echo_info "downloading boost lib"
			download_file "${BOOST_PKG}" "`dirname ${BOOST_PKG}`" "${BOOST_SRC}"
	fi
	echo_info "extracting boost lib"
	tar xzf "${BOOST_PKG}" -C "${PACKAGE_SRC_DIR}"
}

preconfigure_package() {
	prepare_boost
}

make_package() {
	ADD_FLAGS="-I${PACKAGE_SRC_DIR}/${BOOST} -I${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}/include ${BUILD_CFLAGS} --sysroot=${STAGING_DIR}"

	make -j${MAKE_JOBS} \
	   CC="${BUILD_CC}" CXX="${BUILD_CXX}" \
	   ADD_LDFLAGS="${BUILD_LDFLAGS}" ADD_CFLAGS="${ADD_FLAGS}" \
	   PREFIX=${INSTALL_PREFIX} ARCH=arm
}

preinstall_package() {
	for NAME in ${BUILD_TARGETS}; do
		echo_info "patching install command in ${NAME}/Makefile"
		sed -i -E "s;install -s (.*);install -s --strip-program=${BUILD_STRIP} \1;" ${NAME}/Makefile
	done
}

install_package() {
	for NAME in ${BUILD_TARGETS}; do
		make DESTDIR=${STAGING_DIR} install${NAME}
	done
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
		cp -rvf server/etc/snapweb ${STAGING_DIR}/${INSTALL_PREFIX}/share/snapserver/
	fi
}
