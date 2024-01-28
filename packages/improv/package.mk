PACKAGE_NAME="improv-wifi"
PACKAGE_VERSION="0.2"
PACKAGE_COMMIT="36eecde7f7bd89942f8a17079f9f137bcae9d332"
PACKAGE_SRC="https://github.com/MrMarble/${PACKAGE_NAME}/archive/${PACKAGE_COMMIT}.tar.gz"

GO_VERSION="1.21.6"
GO_SRC="https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"

UPX_VERSION="4.2.2"
UPX_SRC="https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-amd64_linux.tar.xz"

unpack_file() {
	local file="$1"
	echo "Unpacking ${file}..."
	if [[ ${file: -7} == '.tar.xz' ]]; then
		tar -xf ${file} -C ${PACKAGE_SRC_DIR} --strip-components=${PACKAGE_SRC_TAR_STRIP}
	elif [[ ${file: -7} == ".tar.gz" || ${src_file: -4} == ".tgz" ]]; then
		tar -xzf ${file} -C ${PACKAGE_SRC_DIR} --strip-components=${PACKAGE_SRC_TAR_STRIP}
	elif [[ ${file: -8} == ".tar.bz2" ]]; then
		tar -xjf ${file} -C ${PACKAGE_SRC_DIR} --strip-components=${PACKAGE_SRC_TAR_STRIP}
	elif [[ ${file: -4} == ".zip" ]]; then
		unzip ${file} -d ${PACKAGE_SRC_DIR}
	fi
}

download_generic() {
	local pkg=$1
	local version="${pkg^^}_VERSION"
	local src="${pkg^^}_SRC"
	local pkg_version="${!version}"
	local pkg_src="${!src}"
	local pkg_download="${PACKAGE_SRC_DOWNLOAD_DIR}/`basename ${pkg_src}`"

	echo_info "downloading ${pkg} ${pkg_version}"
	if [ -e "${pkg_download}" ]; then
		echo_warning "reusing local cache"
	else
		download_file "${pkg_download}" "`dirname ${pkg_download}`" "${pkg_src}" || exit 1
	fi

	unpack_file ${pkg_download} || exit 1
}

configure_package() {
	download_generic go
	download_generic upx
}


make_package() {
	GOBIN="./bin/go"

	CGO_ENABLED=0 \
	GOOS=linux \
	GOARCH=arm \
		${GOBIN} build -a -gcflags=all="-l -B" -buildvcs=false -ldflags="-w -s" -o ${PACKAGE_NAME} .
}

preinstall_package() {
	echo_info "compressing binary with upx"
	./upx --best --ultra-brute ${PACKAGE_NAME}
}

install_package() {
	install -v ${PACKAGE_NAME} ${STAGING_DIR}/usr/bin/
}
