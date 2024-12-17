PACKAGE_NAME="syslog-ng"
PACKAGE_VERSION="3.0.8"
PACKAGE_SRC="https://github.com/syslog-ng/syslog-ng/archive/refs/tags/v${PACKAGE_VERSION}.tar.gz"
# NOTE: packed release contains gitmodules which are REQUIRED. git tag DOES NOT contain them.
PACKAGE_DEPENDS="json-c pcre eventlog"

# NOTE: 3.0.8 seems UNSTABLE, continuous crash every seconod.
# CPU: 3 PID: 3907 Comm: syslog-ng Not tainted 4.9.61 #1
# Hardware name: Amlogic (DT)
# task: ffffffc00a490000 task.stack: ffffffc00a4c8000
# PC is at 0xf6ea22f6
# LR is at 0xf6ead7dd
# pc : [<00000000f6ea22f6>] lr : [<00000000f6ead7dd>] pstate: 000d0030
# sp : 00000000ffcf5498
# x12: 00000000000000af 
# x11: 0000000000000000 x10: 00000000f71e56a3 
# x9 : 00000000ffcf56e8 x8 : 00000000f71e53a9 
# x7 : 00000000000000af x6 : 000000000004caa8 
# x5 : 00000000ffcf54a0 x4 : 0000000000000000 
# x3 : 0000000000000008 x2 : 0000000000000000 
# x1 : 00000000ffcf54a0 x0 : 0000000000000000 

preconfigure_package() {
	autoreconf -fi
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="-DSQLITE_ENABLE_UNLOCK_NOTIFY ${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} --sysconfdir=/etc \
	   --enable-ipv6 \
		 --disable-python \
		 --disable-java \
		 --disable-manpages-install \
		 --disable-all-modules \
		 --disable-ssl \
		 --enable-pcre \
		 --disable-glibtest \
		 --without-compile-date \
		 --with-systemd-journal=optional

		 # --enable-ssl -> breaks with OpenSSL 1.1, requires 1.0
		 # --enable-spoof-source \ # requires libnet
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	for NAME in dqtool loggen pdbtool persist-tool slogencrypt slogkey slogverify update-patterndb ; do 
		rm -vf ${STAGING_DIR}${INSTALL_PREFIX}/bin/${NAME}
	done
}
