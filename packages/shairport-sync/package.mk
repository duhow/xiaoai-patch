PACKAGE_NAME="shairport-sync"
PACKAGE_VERSION="4.3.2"
PACKAGE_SRC="https://github.com/mikebrady/shairport-sync/archive/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc openssl avahi alsa-lib popt libconfig soxr alac"

[ -z "${ENABLE_AIRPLAY_2}" ] && \
ENABLE_AIRPLAY_2="1"

[ "${ENABLE_AIRPLAY_2}" = "1" ] && \
PACKAGE_DEPENDS="${PACKAGE_DEPENDS} nqptp libplist libsodium libgcrypt uuid"

preconfigure_package() {
	autoreconf -fi

  if [ "${ENABLE_AIRPLAY_2}" = "1" ]; then
		# FIXME this build is unstable, as it uses mixed libs from ARM and system.
		# Some commands used to fix this:

		echo_warning "setting a horrible hack to fix the build"

		FILE_XLOCALE=${TOOLCHAIN_DIR}/${BUILD_TARGET}/libc/usr/include/xlocale.h
		FILE_LIBRESOLV=${TOOLCHAIN_DIR}/${BUILD_TARGET}/libc/lib/libresolv.so.2

		mv ${FILE_XLOCALE} ${FILE_XLOCALE}.bak
		ln -s ${STAGING_DIR}/usr/include/locale.h ${FILE_XLOCALE}

		mv ${FILE_LIBRESOLV} ${FILE_LIBRESOLV}.bak
		ln -s ${STAGING_DIR}/lib/libresolv.so.2 ${FILE_LIBRESOLV}
	fi
}

configure_package() {
  EXTRA_FLAGS=""
  if [ "${ENABLE_AIRPLAY_2}" = "1" ]; then
		EXTRA_FLAGS="${EXTRA_FLAGS} --with-airplay-2"
	fi

	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="-I${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}/include --sysroot=${STAGING_DIR} ${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --sysconfdir=/etc --with-sysroot=${STAGING_DIR} \
	   --with-alsa \
	   --with-stdout --with-pipe --with-avahi --with-external-mdns --with-ssl=openssl \
	   --with-soxr --with-apple-alac --with-convolution \
	   --with-piddir=/var --with-metadata \
	   --with-dbus-interface --with-mpris-interface \
	   ${EXTRA_FLAGS}
}

make_package() {
	make -j${MAKE_JOBS}
	EXITCODE=$?

  if [ "${ENABLE_AIRPLAY_2}" = "1" ]; then
		echo_info "undoing toolchain changes"

		rm ${FILE_XLOCALE}
		mv ${FILE_XLOCALE}.bak ${FILE_XLOCALE}

		rm ${FILE_LIBRESOLV}
		mv ${FILE_LIBRESOLV}.bak ${FILE_LIBRESOLV}
	fi

	return ${EXITCODE}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	mkdir -p ${STAGING_DIR}/etc/init.d ${STAGING_DIR}/etc/rc.d

	cp -vf ${PACKAGE_DIR}/config/shairport-sync.conf ${STAGING_DIR}/etc/shairport-sync.conf
	cp -vf ${PACKAGE_DIR}/config/shairport.init ${STAGING_DIR}/etc/init.d/shairport-sync
	chmod 755 ${STAGING_DIR}/etc/init.d/shairport-sync
	ln -svf ../init.d/shairport-sync ${STAGING_DIR}/etc/rc.d/S98shairport-sync
}
