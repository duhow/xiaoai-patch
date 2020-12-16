PACKAGE_NAME="International Components for Unicode"
PACKAGE_VERSION="68.1"
PACKAGE_SRC="https://github.com/unicode-org/icu/releases/download/release-68-1/icu4c-68_1-src.tgz"

# Cross-compile guide: http://starofrainnight-eng.blogspot.com/2013/08/cross-compile-icu-512.html

preconfigure_package() {
	local icu_dir=$(pwd)
	icu_prebuild_dir=${icu_dir}-prebuild
	[[ -d "${icu_prebuild_dir}" ]] && rm -rf ${icu_prebuild_dir}/* || mkdir ${icu_prebuild_dir}
	cd ..
	cp -a ${icu_dir}/* ${icu_prebuild_dir}
	cd ${icu_prebuild_dir}/source
	./configure --enable-rpath
	make_package
	cd ${icu_dir}
}

configure_package() {
	cd source
	# remove -nostdlib from compiler flags, otherwise libicudata will not be linked to (our) libc and becomes soft-float on ARM and breaks MPD build later
	# See: https://github.com/void-linux/void-packages/blob/master/srcpkgs/icu/template
	sed -e 's,-nostdlib,,g' -i ./config/mh-linux

	CC="${BUILD_CC}" CXX="${BUILD_CXX}" CFLAGS="${BUILD_CFLAGS}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} --with-cross-build=${icu_prebuild_dir}/source --enable-rpath --disable-layout --disable-layoutex --disable-tests --disable-samples
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	unset icu_prebuild_dir
}