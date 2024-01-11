PACKAGE_NAME="GCC"
PACKAGE_VERSION="13.2.0"
PACKAGE_SRC="https://ftp.gnu.org/gnu/gcc/gcc-${PACKAGE_VERSION}/gcc-${PACKAGE_VERSION}.tar.xz"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

preconfigure_package() {
	cp ${PACKAGE_DIR}/files/* ${PACKAGE_SRC_DIR}
	cd ${PACKAGE_SRC_DIR}
	./contrib/download_prerequisites
	cd ${PACKAGE_BUILD_DIR}
}

configure_package() {
	local arch_flags
	case ${BUILD_ARCH} in
	"arm"|"armv7")
		arch_flags="--with-float=hard --with-fpu=vfp"
		;;
	*)
		arch_flags=""
		;;
	esac
	
	CC=${BUILD_CC} LDFLAGS=${BUILD_LDFLAGS} CFLAGS="-Os" ${PACKAGE_SRC_DIR}/configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} --target=${BUILD_TARGET} --disable-multilib ${arch_flags} --enable-languages=c,c++ --disable-multilib --with-native-system-header-dir=${STAGING_DIR}/${INSTALL_PREFIX}
}

make_package() {
	make -j${MAKE_JOBS}
}

preinstall_package() {
	# Fixing include-fixed/limits.h like described in: http://www.linuxfromscratch.org/lfs/view/systemd/chapter05/gcc-pass2.html
	# Scenario not the same as building LFS, so probably not the proper way to do it...
	cat ${PACKAGE_SRC_DIR}/gcc/limitx.h ${PACKAGE_SRC_DIR}/gcc/glimits.h ${PACKAGE_SRC_DIR}/gcc/limity.h > ./gcc/include-fixed/limits.h
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	rm -rvf ${STAGING_DIR}/usr/share/gcc-${PACKAGE_VERSION}
}
