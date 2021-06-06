PACKAGE_NAME="bash"
PACKAGE_VERSION="5.1"
PACKAGE_SRC="https://ftp.gnu.org/gnu/bash/bash-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="base glibc"

configure_package() {
	CC=${BUILD_CC} CFLAGS="-Os" ./configure --prefix=${INSTALL_PREFIX} --build=${MACHTYPE} --host=${BUILD_TARGET} 
}

make_package() {
	CC=${BUILD_CC} make -j${MAKE_JOBS}
}

install_package() {
	CC=${BUILD_CC} make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
        rm -rvf ${STAGING_DIR}/usr/share/bash
}
