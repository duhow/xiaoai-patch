PACKAGE_NAME="core_api"
PACKAGE_VERSION="1.0.0"
PACKAGE_DEPENDS="python3"

STAGING_PYTHON=`find ${STAGING_DIR}/usr/lib -maxdepth 1 -type d -name 'python3.*' -print -quit`

configure_package() {
	pip3 install --no-cache-dir --target=${STAGING_PYTHON}/site-packages -r ${WORKSPACE_DIR}/../api/requirements.txt
}

install_package() {
	rm -rf ${STAGING_DIR}/usr/share/api
	cp -rvf ${WORKSPACE_DIR}/../api ${STAGING_DIR}/usr/share/api

	cp -v ${PACKAGE_DIR}/config/api.init ${STAGING_DIR}/etc/init.d/api
	ln -sf ../init.d/api ${STAGING_DIR}/etc/rc.d/S98api
}

postinstall_package() {
	# cleanup of unused data, optimize size
	for NAME in pydoc_data ensurepip 'asyncio/windows_*.py' _osx_support.py test unitest __pycache__ ; do
		rm -rf ${STAGING_PYTHON}/${NAME}
	done

	find "${STAGING_PYTHON}" -type d -name '__pycache__' -exec rm -rf {} \;

	for NAME in test idle_test tests ; do
		find "${STAGING_PYTHON}" -mindepth 2 -type d -name "${NAME}" -exec rm -rf {} \;
	done

	# ignore if failed
	return 0
}
