#!/bin/sh

FOLDER=build-packages/s2t/armv7

echo "[*] Checking for build-package folder"
if [ ! -d "${FOLDER}/" ]; then
  echo "[*] Folder does not exist, skipping."
  exit
fi

echo "[*] Copying content"

rsync -avr ${FOLDER}/* $ROOTFS/

echo "[*] Running root chown"
chown -R root:root $ROOTFS

echo "[!] Deleting additional data"
for FILE in libxml2.so.2.9.7 libstdc++.so.6.0.22* libsbc.so.1.2.1 libreadline.so.7.0 libogg.so.0.8.2 \
	libical.so.0.48.0 libicalss.so.0.48.0 libicalvcal.so.0.48.0 \
	libgthread-2.0.so.0.5501.0 libgobject-2.0.so.0.5501.0 libgmodule-2.0.so.0.5501.0 \
	libglib-2.0.so.0.5501.0 libgio-2.0.so.0.5501.0 \
	libdbus-1.so.3.14.5 libcurl.so.4.4.0 libbluetooth.so.3.18.10; do
  echo "   - ${FILE}"
  rm -f $ROOTFS/usr/lib/$FILE
done
