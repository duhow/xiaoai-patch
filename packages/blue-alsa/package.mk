PACKAGE_NAME="Bluetooth Audio ALSA Backend"
PACKAGE_VERSION="master"
PACKAGE_SRC="https://github.com/Arkq/bluez-alsa/archive/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="alsa-lib bluez sbc mpg123 lame libldac openaptx fdk-aac dbus glib readline libbsd ncurses"

preconfigure_package() {
	autoreconf --install

	if [ ! -e "${BUILD_PKG_CONFIG_LIBDIR}/tinfo.pc" ]; then
		echo_info "creating tinfo.pc file"
		cp ${BUILD_PKG_CONFIG_LIBDIR}/ncurses.pc ${BUILD_PKG_CONFIG_LIBDIR}/tinfo.pc
		sed -i "s/ncurses/tinfo/g" ${BUILD_PKG_CONFIG_LIBDIR}/tinfo.pc
	fi
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   PKG_CONFIG_PATH="${BUILD_PKG_CONFIG_LIBDIR}" \
	   ./configure --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --prefix=${INSTALL_PREFIX} --sysconfdir=/etc --localstatedir=/var \
	   --enable-rfcomm \
	   --enable-a2dpconf \
	   --enable-hcitop \
	   --enable-mp3lame \
	   --enable-mpg123 \
	   --enable-aac \
	   --enable-ldac \
	   --enable-ofono \
	   --enable-aptx --enable-aptx-hd \
	   --with-sysroot="${STAGING_DIR}"
}

premake_package() {
	# FIXME this build is unstable, as it uses mixed libs from ARM and system.
	# Some commands used to fix this:

	echo_error "setting a horrible hack to fix the build"

	FILE_LIBRESOLV=${TOOLCHAIN_DIR}/${BUILD_TARGET}/libc/lib/libresolv.so.2

	mv ${FILE_LIBRESOLV} ${FILE_LIBRESOLV}.bak
	ln -s ${STAGING_DIR}/lib/libresolv.so.2 ${FILE_LIBRESOLV}
}

make_package() {
	make -j${MAKE_JOBS}
	EXITCODE=$?

	echo_info "undoing toolchain changes"

	rm ${FILE_LIBRESOLV}
	mv ${FILE_LIBRESOLV}.bak ${FILE_LIBRESOLV}

	return ${EXITCODE}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
