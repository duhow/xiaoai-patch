PACKAGE_NAME="LDAC Bluetooth Decoder"
PACKAGE_VERSION="master"
#PACKAGE_SRC="https://github.com/anonymix007/libldacdec/archive/refs/heads/master.tar.gz"
PACKAGE_DEPENDS="glibc libsndfile libsamplerate"

preconfigure_package() {
	if [ ! -d "${PACKAGE_SRC_DOWNLOAD_DIR}/libldacdec" ]; then
		cd ${PACKAGE_SRC_DOWNLOAD_DIR}
		git clone --recursive --depth 1 https://github.com/anonymix007/libldacdec
	fi
	cd ${PACKAGE_SRC_DIR}
	cp -rv ${PACKAGE_SRC_DOWNLOAD_DIR}/libldacdec/* ${PACKAGE_SRC_DIR}
}

configure_package () {
	apply_patches
}

make_package() {
	make -j${MAKE_JOBS} CROSS_COMPILE=${BUILD_TARGET}- libldacdec.so
}

install_package() {
	ln -svf libldacdec.so libldacdec.so.1
	cp -avf libldacdec.so libldacdec.so.1 ${STAGING_DIR}/usr/lib/
	cp -vf libldacBT_dec.h ${STAGING_DIR}/usr/include/ldac/libldacBT_dec.h

	PKGDIR="${STAGING_DIR}/usr/lib/pkgconfig"

	cp -vf ${PKGDIR}/ldacBT-enc.pc ${PKGDIR}/ldacBT-dec.pc
	sed -i 's/lldacBT_enc/lldacdec/g' ${PKGDIR}/ldacBT-dec.pc # import lib
	sed -i 's/ldacBT-enc/ldacBT-dec/g' ${PKGDIR}/ldacBT-dec.pc # pkg lib name
	sed -i 's/enc/dec/g' ${PKGDIR}/ldacBT-dec.pc
}
