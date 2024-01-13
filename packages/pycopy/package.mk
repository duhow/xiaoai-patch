PACKAGE_NAME="Python3 - Pycopy"
PACKAGE_VERSION="3.6.1"
PACKAGE_SRC="https://github.com/pfalcon/pycopy/archive/refs/tags/v${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="gcc libffi"
PACKAGE_USE_SEPARATE_BUILD_DIR="true"

PORT_PATH="ports/unix"

preconfigure_package() {
	# no recursive at the moment
	git clone --depth 1 -b "v${PACKAGE_VERSION}" https://github.com/pfalcon/pycopy

	# clone submodules
	git clone --depth 1 https://github.com/pfalcon/pycopy-lib
}

configure_package() {
	# remove problematic/unused deps
	rm -rvf pycopy-lib/uasyncio/benchmark
	find pycopy-lib -maxdepth 2 -type d -name 'testdata' -exec rm -rvf {} \;

	# remove packages
	#for NAME in ast opcode html html.entities html.parser; do
	#	rm -rvf pycopy-lib/${NAME}
	#done

	# copy python modules to build
	#make -C pycopy-lib PREFIX=${PACKAGE_BUILD_DIR}/pycopy/${PORT_PATH}/modules install

	MODULES="argparse base64 datetime getopt gzip zlib cpython-uzlib hmac json logging os \
		pickle socket sqlite3 ssl sys time uasyncio umqtt.simple urequests urllib uyaml"
	for MOD in ${MODULES}; do
		echo "-- installing ${MOD}"
		make -C pycopy-lib PREFIX=${PACKAGE_BUILD_DIR}/pycopy/${PORT_PATH}/modules MOD=${MOD} install
	done

	# do cleanup
	cd ${PACKAGE_BUILD_DIR}/pycopy/${PORT_PATH}/modules
	find . -maxdepth 1 -type f -size 0 -delete
	find . -type l -delete
	rm -vf example_*.py
	cd ${PACKAGE_BUILD_DIR}

	# fix symlinks with default from pycopy, not pycopy-lib
	#for NAME in upip upip_utarfile; do
	#	ln -svf ../../../tools/${NAME}.py pycopy/${PORT_PATH}/modules/${NAME}.py
	#done

}

premake_package() {
	cd pycopy

	# build this package with host arch, not target
	make -j${MAKE_JOBS} -C mpy-cross
}

make_package() {
	cd ${PORT_PATH}

	make submodules

	make -j${MAKE_JOBS} deplibs V=1 \
	CROSS_COMPILE=${BUILD_TARGET}- CC="${BUILD_CC}" \
	CFLAGS_EXTRA="${BUILD_CFLAGS}" LDFLAGS_EXTRA="${BUILD_LDFLAGS}"
}

install_package() {
	make DESTDIR=${STAGING_DIR} PREFIX=${STAGING_DIR}/usr install V=1 \
	CROSS_COMPILE=${BUILD_TARGET}- CC="${BUILD_CC}" \
	CFLAGS_EXTRA="${BUILD_CFLAGS} -Wno-error=enum-int-mismatch" LDFLAGS_EXTRA="${BUILD_LDFLAGS}"
}

postinstall_package() {
	mkdir -p ${STAGING_DIR}/root/.pycopy

	for NAME in python python3; do 
		ln -svf pycopy ${STAGING_DIR}/usr/bin/${NAME}
	done
}
