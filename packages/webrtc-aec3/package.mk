PACKAGE_NAME="webrtc-aec3"
PACKAGE_VERSION="master"
PACKAGE_SRC="https://github.com/ewan-xu/AEC3/archive/refs/heads/${PACKAGE_VERSION}.tar.gz"

preconfigure_package() {
	cp -vf ${PACKAGE_DIR}/files/aec3_cmdline.cc .
	cp -vf ${PACKAGE_DIR}/files/CMakeLists.txt .
	ln -sfn base/rtc_base rtc_base
	ln -sfn base/system_wrappers system_wrappers
	ln -sfn ../base/rtc_base/array_view.h api/array_view.h
}

configure_package() {
	mkdir -p build
	cmake -B build -S . \
		-DCMAKE_SYSTEM_NAME=Linux \
		-DCMAKE_SYSTEM_PROCESSOR=armv7l \
		-DCMAKE_C_COMPILER="${BUILD_CC}" \
		-DCMAKE_CXX_COMPILER="${BUILD_CXX}" \
		-DCMAKE_C_FLAGS="-O3 -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard -ffunction-sections -fdata-sections" \
		-DCMAKE_CXX_FLAGS="-O3 -march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard -ffunction-sections -fdata-sections" \
		-DCMAKE_EXE_LINKER_FLAGS="-static-libstdc++ -static-libgcc -Wl,--gc-sections -s"
}

make_package() {
	make -C build -j${MAKE_JOBS}
}

install_package() {
	cp -vf build/aec3_cmdline ${STAGING_DIR}/usr/bin/aec3_cmdline
	chmod 755 ${STAGING_DIR}/usr/bin/aec3_cmdline
}