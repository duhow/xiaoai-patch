PACKAGE_NAME="python3"
PACKAGE_VERSION="3.9.1"
PACKAGE_SRC="https://www.python.org/ftp/python/${PACKAGE_VERSION}/Python-${PACKAGE_VERSION}.tar.xz"
PACKAGE_DEPENDS="glibc ncurses"

preconfigure_package() {
	# build on self host
	mkdir -p build-host
	cp -a * build-host/
	cd build-host

	./configure
	make -j${MAKE_JOBS} python Parser/pgen
	make install

	if [ $? -gt 0 ]; then
		return 1
	fi

	cd ..
}

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS} -static" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   ./configure --build=${MACHTYPE} --host=${BUILD_TARGET} --target=${BUILD_TARGET} \
	   --prefix=${INSTALL_PREFIX} \
	   ac_cv_file__dev_ptmx=no \
	   ac_cv_file__dev_ptc=no \
	   ac_cv_have_long_long_format=yes \
	   --disable-ipv6 \
	   --disable-shared \
	   --enable-optimizations
}

make_package() {
	make -j${MAKE_JOBS} \
		HOSTPYTHON=${PACKAGE_SRC_DIR}/build-host/python \
		HOSTPGEN=${PACKAGE_SRC_DIR}/build-host/Parser/pgen \
		CROSS_COMPILE_TARGET=yes \
		LDFLAGS="${BUILD_LDFLAGS} -static" LINKFORSHARED=" "
}

install_package() {
	# python build takes too much space, this needs to build static or perform a lot of cleaning
	return 0

	make DESTDIR=${STAGING_DIR} install
}
