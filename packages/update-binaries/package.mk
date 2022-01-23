PACKAGE_NAME="Update all existing binaries in Xiaoai"
PACKAGE_DEPENDS="busybox dropbear dnsmasq htop curl wget alsa mosquitto"

if [ "${BUILD_MODEL}" != "LX01" ]; then
PACKAGE_DEPENDS="${PACKAGE_DEPENDS} blue-alsa"
fi
