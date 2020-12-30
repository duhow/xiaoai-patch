PACKAGE_NAME="libantlr3c"
PACKAGE_VERSION="3.4"
PACKAGE_SRC="https://github.com/antlr/website-antlr3/raw/gh-pages/download/C/libantlr3c-3.4.tar.gz"

configure_package() {
	CC="${BUILD_CC}" CFLAGS="${BUILD_CFLAGS}" LDFLAGS="${BUILD_LDFLAGS}" \
	   CXX="${BUILD_CXX}" CXXFLAGS="${BUILD_CFLAGS}" CPPFLAGS="${BUILD_CFLAGS}" \
	   PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}" PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}" \
	   PKG_CONFIG_PATH="${BUILD_PKG_CONFIG_LIBDIR}" \
	   ./configure --build=${MACHTYPE} --host=${BUILD_TARGET} --target=${BUILD_TARGET} \
	   --prefix=${INSTALL_PREFIX}
}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	echo_info "adding jar file to system /usr/local/bin"
	ANTLR3_JAR="antlr-3.5.2-complete.jar"
	PREFIX_JAVA=/usr/local/share/java
	mkdir -p ${PREFIX_JAVA}
	wget -O ${PREFIX_JAVA}/${ANTLR3_JAR} "https://github.com/antlr/website-antlr3/raw/gh-pages/download/${ANTLR3_JAR}"

	FILE=/usr/local/bin/antlr3
	cat > ${FILE} <<EOF
#!/bin/sh
export CLASSPATH
CLASSPATH=\$CLASSPATH:$PREFIX_JAVA/${ANTLR3_JAR}:$PREFIX_JAVA
/usr/bin/java org.antlr.Tool \$*
EOF

	chmod 755 ${FILE}
}
