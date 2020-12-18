PACKAGE_NAME="Heimdal"
PACKAGE_VERSION="7.7.0"
PACKAGE_SRC="https://github.com/heimdal/heimdal/releases/download/heimdal-7.7.0/heimdal-7.7.0.tar.gz"

configure_package() {
	CC="/usr/bin/gcc" CXX="/usr/bin/g++" CFLAGS="" CXXFLAGS="" CPPFLAGS="" LDFLAGS="" ./configure \
                --build=${MACHTYPE} --host=${MACHTYPE} --target=${BUILD_TARGET} \
				ac_cv_prog_COMPILE_ET=no \
				--enable-static --disable-shared \
				--without-openldap \
				--without-capng \
				--without-sqlite3 \
				--without-libintl \
				--without-openssl \
				--without-berkeley-db \
				--without-readline \
				--without-libedit \
				--without-hesiod \
				--without-x \
				--disable-otp \
				--disable-heimdal-documentation
}

make_package() {
	make -j${MAKE_JOBS} 
}

install_package() {
	cp -PR lib/asn1/asn1_compile ${TOOLCHAIN_DIR}/bin/heimdal_asn1_compile
    cp -PR lib/com_err/compile_et ${TOOLCHAIN_DIR}/bin/heimdal_compile_et
}