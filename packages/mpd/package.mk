PACKAGE_NAME="MPD"
PACKAGE_VERSION="0.22.10"
PACKAGE_DEPENDS="curl alsa-lib flac opus libvorbis libogg faad2 libsndfile lame libid3tag soxr libao libshout chromaprint boost avahi libnfs yajl pcre sqlite3 sndio libupnp ffmpeg zziplib bzip2 libmpdclient"
PACKAGE_SRC="https://github.com/MusicPlayerDaemon/MPD/archive/refs/tags/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

preconfigure_package() {
	# add install_rpath so meson will set rpath of mpd executable
	local install_rpath="\'${INSTALL_PREFIX}/${BUILD_TARGET}/lib:${INSTALL_PREFIX}/lib\'"
	sed -i -e "s/mpd = build_target(/install_rpath = ${install_rpath//\//\\\/}\n\nmpd = build_target(/g" \
		-e "s/install: not is_android and not is_haiku,/install: not is_android and not is_haiku,\n install_rpath: install_rpath,/g" \
		${PACKAGE_SRC_DIR}/meson.build

}

configure_package() {
	# Specify --libdir, or library files will be installed to ${INSTALL_PREFIX}/lib/${BUILD_TARGET} instead of ${INSTALL_PREFIX}/lib
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
		BOOST_ROOT=${BUILD_DIR}/boost \
		meson --cross-file ${TOOLCHAIN_MESON} ${PACKAGE_SRC_DIR} output/release \
		--prefix=${INSTALL_PREFIX}
}

premake_package() {
        # FIXME this build is unstable, as it uses mixed libs from ARM and system.
        # Some commands used to fix this:

        echo_warning "setting a horrible hack to fix the build"

        FILE_XLOCALE=${TOOLCHAIN_DIR}/${BUILD_TARGET}/libc/usr/include/xlocale.h
        FILE_LIBRESOLV=${TOOLCHAIN_DIR}/${BUILD_TARGET}/libc/lib/libresolv.so.2

        mv ${FILE_XLOCALE} ${FILE_XLOCALE}.bak
        ln -s ${STAGING_DIR}/usr/include/locale.h ${FILE_XLOCALE}

        mv ${FILE_LIBRESOLV} ${FILE_LIBRESOLV}.bak
        ln -s ${STAGING_DIR}/lib/libresolv.so.2 ${FILE_LIBRESOLV}
}

make_package() {
	ninja -C output/release
	EXITCODE=$?

        echo_info "undoing toolchain changes"

        rm ${FILE_XLOCALE}
        mv ${FILE_XLOCALE}.bak ${FILE_XLOCALE}

        rm ${FILE_LIBRESOLV}
        mv ${FILE_LIBRESOLV}.bak ${FILE_LIBRESOLV}

        return ${EXITCODE}
}

install_package() {
	DESTDIR=${STAGING_DIR} ninja -C output/release install
}

postinstall_package() {
	mkdir -p ${STAGING_DIR}/etc/init.d ${STAGING_DIR}/etc/rc.d ${STAGING_DIR}/etc/avahi/services

	cp ${PACKAGE_DIR}/config/mpd.conf ${STAGING_DIR}/etc

	cp ${PACKAGE_DIR}/config/mpd.init ${STAGING_DIR}/etc/init.d/mpd
	chmod +x ${STAGING_DIR}/etc/init.d/mpd
	ln -s /etc/init.d/mpd ${STAGING_DIR}/etc/rc.d/S93mpd

	cp ${PACKAGE_DIR}/config/mpd.service ${STAGING_DIR}/etc/avahi/services
}
