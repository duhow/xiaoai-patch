PACKAGE_NAME="Samba"
PACKAGE_VERSION="4.11.3"
PACKAGE_DEPENDS="jansson libtirpc gnutls heimdal"
PACKAGE_SRC="https://download.samba.org/pub/samba/stable/samba-4.11.3.tar.gz"

# patches obtained from LibreELEC repo to enable cross-building

configure_package() {
	export COMPILE_ET=${TOOLCHAIN_DIR}/bin/heimdal_compile_et
	export ASN1_COMPILE=${TOOLCHAIN_DIR}/bin/heimdal_asn1_compile

	local samba_options="--prefix=${INSTALL_PREFIX} \
				--disable-python \
				--without-ad-dc \
				--without-libarchive \
				--without-acl-support \
				--without-ldb-lmdb \
				--without-ldap \
				--without-ads \
				--without-pam"

    case ${BUILD_ARCH} in
	"arm"|"armv7")
        local cross_compile="true"
        local cross_exe="qemu-arm-static -L ${STAGING_DIR}"
        local cross_hostcc="gcc"
        ;;
    "x86")
        local cross_compile="true"
        local cross_exe="qemu-i386-static -L ${STAGING_DIR}"
        local cross_hostcc="gcc"
        ;;
    esac

    if [[ "${cross_compile}" == "true" ]]; then
        CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS} -ltinfo" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" ./configure --cross-compile --cross-execute="${cross_exe}" --hostcc="${cross_hostcc}" --bundled-libraries='!asn1_compile,!compile_et' ${samba_options}
    else
        CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS} -ltinfo" PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" ./configure --bundled-libraries='!asn1_compile,!compile_et' ${samba_options}
    fi        
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}
