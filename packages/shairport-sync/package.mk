PACKAGE_NAME="shairport-sync"
PACKAGE_VERSION="3.3.9"
PACKAGE_SRC="https://github.com/mikebrady/shairport-sync/archive/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc openssl avahi alsa-lib popt libconfig soxr alac"

preconfigure_package() {
	autoreconf -fi
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="-I${STAGING_DIR}/${INSTALL_PREFIX}/${BUILD_TARGET}/include --sysroot=${STAGING_DIR} ${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --sysconfdir=/etc --with-sysroot=${STAGING_DIR} \
	   --with-alsa \
	   --with-stdout --with-pipe --with-avahi --with-ssl=openssl \
	   --with-soxr --with-apple-alac --with-convolution \
	   --with-piddir=/var --with-metadata
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	mkdir -p ${STAGING_DIR}/etc/init.d ${STAGING_DIR}/etc/rc.d

	cp -vf ${PACKAGE_DIR}/config/shairport.init ${STAGING_DIR}/etc/init.d/shairport-sync
	chmod 755 ${STAGING_DIR}/etc/init.d/shairport-sync
	ln -svf ../init.d/shairport-sync ${STAGING_DIR}/etc/rc.d/S98shairport-sync
}
