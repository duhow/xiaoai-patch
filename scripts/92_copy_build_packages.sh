#!/bin/sh

FOLDER=build-packages/s2t/armv7

echo "[*] Checking for build-package folder"
if [ ! -d "${FOLDER}/" ]; then
  echo "[*] Folder does not exist, skipping."
  exit
fi

echo "[*] Copying content"

rsync -avr ${FOLDER}/* $ROOTFS/

if [ $? -gt 0 ]; then
  echo "[!] There was some error during rsync execution or copy."
  exit 1
fi

echo "[!] Deleting additional data"
for FILE in libxml2.so.2.9.7 libxml2.so.2.9.3 libstdc++.so.6.0.22* libsbc.so.1.2.1 libreadline.so.7.0 libogg.so.0.8.2 \
	libical.so.0.48.0 libicalss.so.0.48.0 libicalvcal.so.0.48.0 \
	libgthread-2.0.so.0.5500.0 libgobject-2.0.so.0.5500.0 libgmodule-2.0.so.0.5500.0 \
	libglib-2.0.so.0.5500.0 libgio-2.0.so.0.5500.0 \
	libgthread-2.0.so.0.5501.0 libgobject-2.0.so.0.5501.0 libgmodule-2.0.so.0.5501.0 \
	libglib-2.0.so.0.5501.0 libgio-2.0.so.0.5501.0 \
	libgio-2.0.so.0.5000.1 libglib-2.0.so.0.5000.1 libgmodule-2.0.so.0.5000.1 libgobject-2.0.so.0.5000.1 \
	libdbus-1.so.3.14.5 dbus-1/dbus-daemon-launch-helper \
	libcurl.so.4.4.0 libbluetooth.so.3.18.10 libpcre.so.1.2.9 libpcre.so.1.2.6 \
	libpcreposix.so.0.0.5 \
	libhistory.so.7.0 \
	libfdk-aac.so.1.0.0 libfdk-aac.so.2.0.2 \
	libFLAC.so.8.3.0 libspeexdsp.so.1.5.0 \
	libopus.so.0.5.3 libopus.so.0.6.1 \
	libopusfile.so.0.4.4 libopusurl.so.0.4.4 \
	libsndfile.so.1.0.28 \
	libffi.so.6.0.4 libexpat.so.1.6.7 \
	libz.so.1.2.8 libz.so.1.2.11 \
	libnghttp2.so.14.13.2; do
  rm -vf $ROOTFS/usr/lib/$FILE
done

# delete alsa sounds
for FILE in Front_Left Front_Right Front_Center Noise ; do
  rm -vf $ROOTFS/usr/share/sounds/alsa/${FILE}.wav
done

# delete unwanted binaries, both from source root image or compiled
for FILE in wget-ssl libtool libtoolize iperf drill dlna usb_monitor strace; do
  rm -vf $ROOTFS/usr/bin/$FILE
done

# delete bluez unused
for FILE in isotest pcretest rctest mpris-proxy bluemoon \
  l2test l2ping btmgmt gatttool bccmd sdptool ciptool \
  glib-* ; do
  rm -vf $ROOTFS/usr/bin/$FILE
done

# deleting sbin unused (!)
for FILE in rtwpriv rtlbtmp mlanutl ptp4l timemaster \
  zdump zic nscd iconvconfig ; do
  rm -vf $ROOTFS/usr/sbin/$FILE
done

for FILE in sln ldconfig; do
  rm -vf $ROOTFS/sbin/$FILE
done

echo "[!] Fixing old libs"

libraries_upgrade="
libreadline.so.7 libreadline.so
libicalvcal.so.0 libicalvcal.so
libicalss.so.0 libicalss.so
libical.so.0 libical.so
libffi.so.6 libffi.so
libfdk-aac.so.1 libfdk-aac.so
libFLAC.so.8 libFLAC.so
libhistory.so.7 libhistory.so
libconfig.so.11.0.2 libconfig.so.11.1.0
libconfig++.so.11.0.2 libconfig++.so.11.1.0
libcurl.so.4.5.0 libcurl.so.4
libnghttp2.so.14.16.2 libnghttp2.so.14
"

echo "$libraries_upgrade" | while read -r entry; do
  libold=$(echo "$entry" | cut -d' ' -f1)
  libnew=$(echo "$entry" | cut -d' ' -f2)

  if [ -z "${libold}" ] || [ -z "${libnew}" ]; then
    continue
  fi

  FILE="$ROOTFS/usr/lib/$libold"
  if [ -h "$FILE" ] || [ -e "$FILE" ]; then
    rm -fv $FILE
  fi
  ln -sv $libnew $FILE
done

if [ -d "${ROOTFS}/usr/lib/gconv" ]; then
  echo "[*] Deleting some gconv files"
  GCONV_KEEP="ANSI_X3.110 ARMSCII-8 BIG5 CP1252 ECMA-CYRILLIC IBM850 ISO8859-1 ISO8859-11 \
	      UNICODE UTF-16 UTF-32"
  for FILE in ${ROOTFS}/usr/lib/gconv/*.so; do
    (echo "${GCONV_KEEP}" | grep -q "$(basename $FILE .so)") || rm -vf ${FILE}
  done
fi

if [ -f "${ROOTFS}/usr/sbin/avahi-daemon" ]; then
  echo "[*] Adding avahi user entries"
  echo "netdev:x:108:" >> $ROOTFS/etc/group
  echo "avahi:x:115:" >> $ROOTFS/etc/group
  echo "avahi:x:108:115:Avahi mDNS daemon:/var/run/avahi-daemon:/bin/false" >> $ROOTFS/etc/passwd
fi

if [ -f "${ROOTFS}/usr/bin/dbus-daemon" ]; then
  echo "[*] Adding dbus user entries"
  echo "messagebus:x:106:110::/nonexistent:/bin/false" >> $ROOTFS/etc/passwd
  echo "messagebus:x:110:" >> $ROOTFS/etc/group

  echo "[*] Fixing new dbus"
  # new one is dbus-1.0
  rm -rf $ROOTFS/usr/lib/dbus-1
  rm $ROOTFS/usr/sbin/dbus-daemon
  ln -sf /usr/bin/dbus-daemon $ROOTFS/usr/sbin/dbus-daemon
fi

if [ -f "${ROOTFS}/usr/bin/upmpdcli" ]; then
  echo "[*] Adding upmpdcli user entries"
  echo "upmpdcli:x:199:199::/nonexistent:/bin/false" >> $ROOTFS/etc/passwd
  echo "upmpdcli:x:199:" >> $ROOTFS/etc/group

  # required for LX01 Android permissions for users
  echo "aid_inet:x:3003:upmpdcli" >> $ROOTFS/etc/group
  echo "aid_inet_raw:x:3004:upmpdcli" >> $ROOTFS/etc/group
fi

# swap button keys

TRIGGER_FOLDER=${ROOTFS}/etc/triggerhappy/triggers.d
VOLUME_FILE=${TRIGGER_FOLDER}/volume.conf
if [ "${MODEL}" = "lx05" ] && [ -f "${VOLUME_FILE}" ]; then
  echo "[*] Patching inverse volume controls"

  cat << EOF > ${VOLUME_FILE}
KEY_VOLUMEUP         1  /bin/volume up
KEY_MENU             1  /bin/volume down
EOF

  chmod 644 ${VOLUME_FILE}

  [ -f "${TRIGGER_FOLDER}/listener.conf" ] && \
    sed -i "s/KEY_HOME/KEY_ENTER/" ${TRIGGER_FOLDER}/listener.conf
fi

if [ "${MODEL}" = "l09a" ] && [ -f "${VOLUME_FILE}" ]; then
  echo "[*] Patching inverse volume controls"

  sed -i "s/KEY_MENU/KEY_HOME/" ${VOLUME_FILE}

  [ -f "${TRIGGER_FOLDER}/listener.conf" ] && \
    sed -i "s/KEY_HOME/KEY_MENU/" ${TRIGGER_FOLDER}/listener.conf
fi
