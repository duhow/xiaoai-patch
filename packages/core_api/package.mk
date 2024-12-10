PACKAGE_NAME="core_api"
PACKAGE_VERSION="1.0.0"
PACKAGE_DEPENDS="python3"

PYTHONDIR=`find ${STAGING_DIR}/usr/lib -maxdepth 1 -type d -name 'python3.*' -print -quit`

configure_package() {
	pip3 install --no-cache-dir --target=${PYTHONDIR}/site-packages -r ${WORKSPACE_DIR}/../api/requirements.txt
}

install_package() {
	cp -rvf ${WORKSPACE_DIR}/../api ${STAGING_DIR}/usr/share/api
}

postinstall_package() {
	# cleanup of unused data, optimize size
	for NAME in pydoc_data ensurepip 'asyncio/windows_*.py' _osx_support.py test unitest __pycache__ ; do
		rm -rf ${PYTHONDIR}/${NAME}
	done

	find "${PYTHONDIR}" -type d -name '__pycache__' -exec rm -rf {} \;

	for NAME in test idle_test tests ; do
		find "${PYTHONDIR}" -mindepth 2 -type d -name "${NAME}" -exec rm -rf {} \;
	done

	# ignore if failed
	return 0
}
