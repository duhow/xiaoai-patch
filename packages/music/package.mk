PACKAGE_NAME="Packages for music playing"
PACKAGE_DEPENDS="mpg123 vorbis-tools opus-tools mpd mpc ffmpeg shairport-sync-metadata snapcast squeezelite"

# adds 628 KB to final compressed image
if [ "${BUILD_MODEL}" != "LX01" ]; then
  PACKAGE_DEPENDS="${PACKAGE_DEPENDS} upmpdcli"
fi
