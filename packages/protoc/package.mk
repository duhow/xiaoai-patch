PACKAGE_NAME="protoc"
PACKAGE_VERSION="3.11.4"
PROTOC_ZIP="protoc-${PACKAGE_VERSION}-linux-x86_64.zip"
PACKAGE_SRC="https://github.com/protocolbuffers/protobuf/releases/download/v${PACKAGE_VERSION}/${PROTOC_ZIP}"

install_package() {
	mkdir -p "${TOOLCHAIN_DIR}/bin"
	cp -vf "${PACKAGE_SRC_DIR}/bin/protoc" "${TOOLCHAIN_DIR}/bin/protoc" || return 1
	chmod +x "${TOOLCHAIN_DIR}/bin/protoc" || return 1
}