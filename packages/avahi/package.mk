PACKAGE_NAME="Avahi"
PACKAGE_VERSION="0.8"
PACKAGE_DEPENDS="libdaemon libevent glib dbus gdbm"
PACKAGE_SRC="http://avahi.org/download/avahi-${PACKAGE_VERSION}.tar.gz"

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./autogen.sh --build=${MACHTYPE} --host=${BUILD_TARGET} \
	   --prefix=${INSTALL_PREFIX} --sysconfdir=/etc --localstatedir=/var \
	   --with-distro=debian \
	   --disable-qt3 --disable-qt4 --disable-qt5 \
	   --disable-gtk --disable-gtk3 \
	   --disable-python --disable-mono \
	   --disable-manpages
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	echo_info "adding rc.d start for avahi"
	RCD_FOLDER="${STAGING_DIR}/etc/rc.d"
	mkdir -p ${RCD_FOLDER}
	ln -s /etc/init.d/avahi-daemon ${RCD_FOLDER}/S90avahi
}
