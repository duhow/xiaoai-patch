PACKAGE_NAME="python3"
PACKAGE_VERSION="3.9.18"
PACKAGE_SRC="https://www.python.org/ftp/python/${PACKAGE_VERSION}/Python-${PACKAGE_VERSION}.tar.xz"
PACKAGE_DEPENDS="glibc ncurses expat"

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
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	./configure --build=${MACHTYPE} --host=${BUILD_TARGET} --target=${BUILD_TARGET} \
	--prefix=${INSTALL_PREFIX} \
	ac_cv_file__dev_ptmx=no \
	ac_cv_file__dev_ptc=no \
	ac_cv_have_long_long_format=yes \
	--enable-optimizations \
	--with-lto \
	--enable-shared \
	--disable-ipv6 \
	--disable-test-modules \
	--without-doc-strings \
	--with-ensurepip=install \
	--with-system-expat=${INSTALL_PREFIX} \
	--with-threads
}

make_package() {
	make -j${MAKE_JOBS} \
		HOSTPYTHON=${PACKAGE_SRC_DIR}/build-host/python \
		HOSTPGEN=${PACKAGE_SRC_DIR}/build-host/Parser/pgen \
		CROSS_COMPILE_TARGET=yes \
		LDFLAGS="${BUILD_LDFLAGS}" LINKFORSHARED=" "
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	STAGING_PYTHON=`find ${STAGING_DIR}/usr/lib -maxdepth 1 -type d -name 'python3.*' -print -quit`
	echo_notice "Python dir: ${STAGING_PYTHON}"

	# cleanup of unused data, optimize size
	for NAME in pydoc_data ensurepip 'asyncio/windows_*.py' _osx_support.py test unitest __pycache__ ; do
		rm -rf ${STAGING_PYTHON}/${NAME}
	done

	find "${STAGING_PYTHON}" -type d -name '__pycache__' -exec rm -rf {} \;

	for NAME in test idle_test tests ; do
		find "${STAGING_PYTHON}" -mindepth 2 -type d -name "${NAME}" -exec rm -rf {} \;
	done

	export PYTHONPATH=""
	unset PYTHONPATH

	# IMPORTANT: remove built python for host, as causes conflict
	for NAME in python3 pip3 ; do
	  rm -vf /usr/local/bin/${NAME}
	done

	# ignore if failed
	return 0
}
