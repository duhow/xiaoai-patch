PACKAGE_NAME="D-Bus"
PACKAGE_VERSION="1.14.8"
PACKAGE_SRC="https://gitlab.freedesktop.org/dbus/dbus/-/archive/dbus-${PACKAGE_VERSION}/dbus-dbus-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="expat"

preconfigure_package() {
	autoreconf -fi
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" \
	   CXX="${BUILD_CXX}" \
	   LDFLAGS="${BUILD_LDFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --prefix=${INSTALL_PREFIX} --sysconfdir=/etc --localstatedir=/var
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

postinstall_package() {
	mkdir -p ${STAGING_DIR}/etc/init.d ${STAGING_DIR}/etc/rc.d

	cp -vf ${PACKAGE_DIR}/config/dbus.init ${STAGING_DIR}/etc/init.d/dbus
	chmod 755 ${STAGING_DIR}/etc/init.d/dbus
	ln -sf ../init.d/dbus ${STAGING_DIR}/etc/rc.d/S60dbus
}
