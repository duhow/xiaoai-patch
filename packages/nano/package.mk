PACKAGE_NAME="nano"
PACKAGE_VERSION="7.0"
PACKAGE_SRC="https://www.nano-editor.org/dist/v${PACKAGE_VERSION:0:1}/nano-${PACKAGE_VERSION}.tar.xz"
PACKAGE_DEPENDS="glibc ncurses"

preconfigure_package(){
	autoreconf -fi
}

configure_package() {
	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" \
		CFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
		LDFLAGS="-lm -ltinfo ${BUILD_LDFLAGS}" \
		PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
		PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} \
		--disable-browser --disable-color \
		--disable-extra --disable-formatter --disable-help \
		--disable-libmagic --disable-linter --disable-mouse \
		--disable-nanorc --disable-speller  --disable-largefile \
		--enable-tiny
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
