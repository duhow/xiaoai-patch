PACKAGE_NAME="squeezelite"
PACKAGE_VERSION="master"
PACKAGE_SRC="https://github.com/ralph-irving/squeezelite/archive/refs/heads/master.tar.gz"
PACKAGE_DEPENDS="alsa-lib openssl alac soxr faad2 opus opusfile mpg123 ffmpeg"

make_package() {
	make -j${MAKE_JOBS} \
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   OPTS="-DFFMPEG -DNO_MAD -DALAC -DOPUS -DRESAMPLE -DLINKALL -DVISEXPORT -DDSD -DUSE_SSL -marm -I${STAGING_DIR}${INSTALL_PREFIX}/include/opus -I${STAGING_DIR}${INSTALL_PREFIX}/include/alac"
}

preinstall_package() {
	# strip binary file to remove debug info and reduce size
	${BUILD_STRIP} ./${PACKAGE_NAME}
}

install_package() {
	install -v squeezelite ${STAGING_DIR}/usr/bin
	cp -vf ${PACKAGE_DIR}/config/${PACKAGE_NAME}.conf ${STAGING_DIR}/etc/${PACKAGE_NAME}

	install -v ${PACKAGE_DIR}/config/${PACKAGE_NAME}.init ${STAGING_DIR}/etc/init.d/${PACKAGE_NAME}
	ln -svf ../init.d/${PACKAGE_NAME} ${STAGING_DIR}/etc/rc.d/S99${PACKAGE_NAME}
}
