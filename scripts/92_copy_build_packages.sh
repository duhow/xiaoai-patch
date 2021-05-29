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
for FILE in libxml2.so.2.9.7 libxml2.so.2.9.3 libstdc++.so.6.0.22* libsbc.so.1.2.1 libreadline.so.7.0 libogg.so.0.8.2 \
	libical.so.0.48.0 libicalss.so.0.48.0 libicalvcal.so.0.48.0 \
	libgthread-2.0.so.0.5500.0 libgobject-2.0.so.0.5500.0 libgmodule-2.0.so.0.5500.0 \
	libglib-2.0.so.0.5500.0 libgio-2.0.so.0.5500.0 \
	libgthread-2.0.so.0.5501.0 libgobject-2.0.so.0.5501.0 libgmodule-2.0.so.0.5501.0 \
	libglib-2.0.so.0.5501.0 libgio-2.0.so.0.5501.0 \
	libdbus-1.so.3.14.5 dbus-1/dbus-daemon-launch-helper \
	libcurl.so.4.4.0 libbluetooth.so.3.18.10 libpcre.so.1.2.9 libpcre.so.1.2.6 \
	libpcreposix.so.0.0.5 libopus.so.0.6.1 libffi.so.6.0.4 libexpat.so.1.6.7 libcrypto.so.1.0.0; do
  rm -vf $ROOTFS/usr/lib/$FILE
done

for FILE in hcidump btmgmt hciattach wget-ssl; do
  rm -vf $ROOTFS/usr/bin/$FILE
done

echo "[!] Fixing old libs"
for FILE in libreadline.so.7 libicalvcal.so.0 libicalss.so.0 libical.so.0 libffi.so.6; do
  rm -vf $ROOTFS/usr/lib/$FILE
done
ln -s libreadline.so.8 $ROOTFS/usr/lib/libreadline.so.7
ln -s libicalvcal.so.3 $ROOTFS/usr/lib/libicalvcal.so.0
ln -s libicalss.so.3 $ROOTFS/usr/lib/libicalss.so.0
ln -s libical.so.3 $ROOTFS/usr/lib/libical.so.0
ln -s libffi.so.7 $ROOTFS/usr/lib/libffi.so.6

echo "[*] Fixing new dbus"
# new one is dbus-1.0
rm -rf $ROOTFS/usr/lib/dbus-1
rm $ROOTFS/usr/sbin/dbus-daemon
ln -sf /usr/bin/dbus-daemon $ROOTFS/usr/sbin/dbus-daemon


echo "[*] Adding service user entries"

echo "messagebus:x:106:110::/nonexistent:/bin/false" >> $ROOTFS/etc/passwd
echo "avahi:x:108:115:Avahi mDNS daemon:/var/run/avahi-daemon:/bin/false" >> $ROOTFS/etc/passwd
echo "upmpdcli:x:199:199::/nonexistent:/bin/false" >> $ROOTFS/etc/passwd

echo "netdev:x:108:" >> $ROOTFS/etc/group
echo "messagebus:x:110:" >> $ROOTFS/etc/group
echo "avahi:x:115:" >> $ROOTFS/etc/group
echo "upmpdcli:x:199:" >> $ROOTFS/etc/group
