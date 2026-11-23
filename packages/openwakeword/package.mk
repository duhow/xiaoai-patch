PACKAGE_NAME="openwakeword"
PACKAGE_VERSION="master"
PACKAGE_SRC="https://github.com/rhasspy/openWakeWord-cpp/archive/${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="glibc alsa-utils onnxruntime"

make_package() {
    ONNX_STAGING="${STAGING_DIR}${INSTALL_PREFIX}"
    ONNX_LIB="${ONNX_STAGING}/lib/libonnxruntime.so"
    ONNX_INC="${ONNX_STAGING}/include"

    if [ ! -f "${ONNX_LIB}" ]; then
        echo "ERROR: ${ONNX_LIB} not found. Build onnxruntime package first."
        return 1
    fi

    mkdir -p lib/armv7l/lib lib/armv7l/include build

    cp -avf "${ONNX_STAGING}/lib/"libonnxruntime.so* lib/armv7l/lib/
    cp -rv "${ONNX_INC}/"* lib/armv7l/include/

    sed -i '1i #include <stdlib.h>' src/main.cpp
    sed -i 's|#include <filesystem>|#include <experimental/filesystem>|g' src/*.cpp
    sed -i 's|using namespace filesystem;|using namespace std::experimental::filesystem;|g' src/*.cpp
    sed -i 's|std::filesystem|std::experimental::filesystem|g' src/*.cpp

    sed -i 's|GetInputNameAllocated|GetInputName|g' src/*.cpp
    sed -i 's|GetOutputNameAllocated|GetOutputName|g' src/*.cpp
    sed -i 's|InputName\.get()|InputName|g' src/*.cpp
    sed -i 's|OutputName\.get()|OutputName|g' src/*.cpp

    ${BUILD_CXX} -std=c++17 -O3 ${BUILD_CXXFLAGS} ${BUILD_LDFLAGS} \
        -I lib/armv7l/include \
        -I lib/armv7l/include/core/session \
        src/*.cpp \
        -L lib/armv7l/lib -lonnxruntime \
        -lstdc++fs -lpthread -ldl -Wl,-rpath=/usr/lib \
        -o build/openwakeword
}

install_package() {
    OWW_FOLDER="${STAGING_DIR}${INSTALL_PREFIX}/share/openwakeword"
    mkdir -p "${OWW_FOLDER}/models"
    mkdir -p "${STAGING_DIR}${INSTALL_PREFIX}/bin"

    cp -v build/openwakeword "${STAGING_DIR}${INSTALL_PREFIX}/bin/openwakeword"
    cp -v "${PACKAGE_DIR}/config/launcher" "${STAGING_DIR}${INSTALL_PREFIX}/bin/openwakeword_launcher"

    chmod 755 "${STAGING_DIR}${INSTALL_PREFIX}/bin/openwakeword"
    chmod 755 "${STAGING_DIR}${INSTALL_PREFIX}/bin/openwakeword_launcher"

    cp -v models/melspectrogram.onnx "${OWW_FOLDER}/models/"
    cp -v models/embedding_model.onnx "${OWW_FOLDER}/models/"
    cp -v models/alexa*.onnx "${OWW_FOLDER}/models/"
}