PACKAGE_NAME="sox"
PACKAGE_VERSION="14.4.2"
PACKAGE_SRC="https://github.com/chirlu/sox/archive/refs/tags/sox-${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="alsa libvorbis opus flac lame wget libsndfile soxr"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

configure_package() {
	LDFLAGS="-lm" \
	PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" \
	PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	cmake \
	-DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_CMAKE} \
	-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
	${PACKAGE_SRC_DIR}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	BINDIR=${STAGING_DIR}/${INSTALL_PREFIX}/bin
	install -v src/sox ${BINDIR}/sox
	ln -svf sox ${BINDIR}/rec
	ln -svf sox ${BINDIR}/play
}
