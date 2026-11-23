PACKAGE_NAME="onnxruntime"
PACKAGE_VERSION="1.7.2"
#PACKAGE_SRC="https://github.com/microsoft/onnxruntime/archive/refs/tags/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_GIT="https://github.com/Liquid4All/onnxruntime.git"
PACKAGE_DEPENDS="protoc"

preconfigure_package() {
	if [ ! -d "${PACKAGE_SRC_DOWNLOAD_DIR}/${PACKAGE_VERSION}/src" ]; then
		mkdir -p ${PACKAGE_SRC_DOWNLOAD_DIR}/${PACKAGE_VERSION} || true
		cd "${PACKAGE_SRC_DOWNLOAD_DIR}/${PACKAGE_VERSION}" || return 1

		git clone --depth 1 --branch "v${PACKAGE_VERSION}" "${PACKAGE_GIT}" "src" || return 1

		cd "src" || return 1
		git submodule update --init --depth 1 \
			cmake/external/onnx \
			cmake/external/protobuf \
			cmake/external/nsync \
			cmake/external/re2 \
			cmake/external/date \
			cmake/external/eigen \
			cmake/external/flatbuffers \
			cmake/external/SafeInt \
			cmake/external/optional-lite \
			cmake/external/wil \
			cmake/external/mp11 \
			cmake/external/json \
			cmake/external/mimalloc || return 1
	fi

	rm -rf "${PACKAGE_SRC_DIR:?}"/* "${PACKAGE_SRC_DIR}"/.[!.]* 2>/dev/null
	cp -r "${PACKAGE_SRC_DOWNLOAD_DIR}/${PACKAGE_VERSION}/src/"* "${PACKAGE_SRC_DIR}/" || return 1
}

configure_package() {
    cd "${PACKAGE_SRC_DIR}"
    rm -rf build_${BUILD_ARCH}
    mkdir -p build_${BUILD_ARCH}
    cd build_${BUILD_ARCH}

    cmake ../cmake \
		-DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_SYSROOT_CMAKE}" \
		-DCMAKE_MAKE_PROGRAM=/usr/bin/make \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
		-Donnxruntime_CROSS_COMPILING=ON \
		-Donnxruntime_BUILD_SHARED_LIB=ON \
		-Donnxruntime_BUILD_UNIT_TESTS=OFF \
		-Donnxruntime_ENABLE_PYTHON=OFF \
		-Donnxruntime_USE_OPENMP=OFF \
		-Donnxruntime_ENABLE_TRAINING=OFF \
		-Donnxruntime_DISABLE_CONTRIB_OPS=ON \
		-Donnxruntime_DISABLE_ML_OPS=ON \
		-Donnxruntime_DEV_MODE=OFF \
		-Donnxruntime_USE_PREINSTALLED_EIGEN=OFF \
		-Donnxruntime_USE_FULL_PROTOBUF=OFF \
		-Donnxruntime_ENABLE_TELEMETRY=OFF \
		-DONNX_USE_LITE_PROTO=ON \
		-DPYTHON_EXECUTABLE=/usr/bin/python3 \
		-DProtobuf_PROTOC_EXECUTABLE="${TOOLCHAIN_DIR}/bin/protoc" \
		-DONNX_CUSTOM_PROTOC_EXECUTABLE="${TOOLCHAIN_DIR}/bin/protoc" \
		-DCMAKE_CXX_STANDARD=14 2>&1 | tee cmake_config.log

    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        echo "=== CMAKE ERRORS ==="
        grep -B 2 -A 8 -i "CMake Error" cmake_config.log
        return 1
    fi
}

make_package() {
    cd "${PACKAGE_SRC_DIR}/build_${BUILD_ARCH}"
    make -j"${MAKE_JOBS}"
    make -j"${MAKE_JOBS}" nsync_cpp
}

install_package() {
    cd "${PACKAGE_SRC_DIR}/build_${BUILD_ARCH}"
    mkdir -p "${STAGING_DIR}${INSTALL_PREFIX}/lib"
    mkdir -p "${STAGING_DIR}${INSTALL_PREFIX}/include"

    rm -f "${STAGING_DIR}${INSTALL_PREFIX}/lib/libonnxruntime.a"
    cp -avf libonnxruntime.so* "${STAGING_DIR}${INSTALL_PREFIX}/lib/"
    cp -rv "${PACKAGE_SRC_DIR}/include/onnxruntime/"* "${STAGING_DIR}${INSTALL_PREFIX}/include/"
}