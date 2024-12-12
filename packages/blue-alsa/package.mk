PACKAGE_NAME="Bluetooth Audio ALSA Backend"
PACKAGE_VERSION="4.3.0"
PACKAGE_SRC="https://github.com/Arkq/bluez-alsa/archive/refs/tags/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="alsa-lib bluez sbc dbus glib readline libbsd ncurses"
BUILD_CODECS=""

build_opts_extend() {
	PACKAGE_DEPENDS="${PACKAGE_DEPENDS} $1"
	BUILD_CODECS="${BUILD_CODECS} --enable-$2"
}

[ -z "${ENABLE_MPG123}" ] && ENABLE_MPG123=1
[ -z "${ENABLE_MP3LAME}" ] && ENABLE_MP3LAME=1
[ -z "${ENABLE_AAC}" ] && ENABLE_AAC=1
[ -z "${ENABLE_LDAC}" ] && ENABLE_LDAC=1
[ -z "${ENABLE_APTX}" ] && ENABLE_APTX=1
[ -z "${ENABLE_LC3PLUS}" ] && ENABLE_LC3PLUS=0
[ -z "${ENABLE_MSBC}" ] && ENABLE_MSBC=0
[ -z "${ENABLE_FASTSTREAM}" ] && ENABLE_FASTSTREAM=1

[ "${ENABLE_MPG123}" = 1 ] && build_opts_extend mpg123 mpg123
[ "${ENABLE_MP3LAME}" = 1 ] && build_opts_extend lame mp3lame
[ "${ENABLE_AAC}" = 1 ] && build_opts_extend fdk-aac aac
[ "${ENABLE_LDAC}" = 1 ] && build_opts_extend libldac ldac
[ "${ENABLE_APTX}" = 1 ] && build_opts_extend openaptx "aptx --enable-aptx-hd --with-libopenaptx"
[ "${ENABLE_LC3PLUS}" = 1 ] && build_opts_extend lc3plus lc3plus
[ "${ENABLE_MSBC}" = 1 ] && build_opts_extend spandsp msbc
[ "${ENABLE_FASTSTREAM}" = 1 ] && build_opts_extend "" faststream

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
	   ${BUILD_CODECS} \
	   --enable-ofono \
	   --with-sysroot="${STAGING_DIR}"
}

premake_package() {
	# FIXME this build is unstable, as it uses mixed libs from ARM and system.
	# Some commands used to fix this:

	echo_warning "setting a horrible hack to fix the build"

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
