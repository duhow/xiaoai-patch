PACKAGE_NAME="Update all existing libs in Xiaoai"
PACKAGE_DEPENDS="glibc zlib gcc openssl ncurses readline libogg opus pcre sbc libical glib curl expat libffi dbus alsa-lib libxml"

if [ "${BUILD_MODEL}" != "LX01" ]; then
PACKAGE_DEPENDS="${PACKAGE_DEPENDS} bluez"
fi
