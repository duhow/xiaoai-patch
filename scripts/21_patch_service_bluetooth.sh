#!/bin/sh


AMOUNT=0
FILE=$ROOTFS/etc/init.d/check_mac
if [ -f "${FILE}" ]; then
  SHA=$(shasum $FILE | awk '{print $1}')
  if [ "$SHA" = "ee8e4573719da3defd72de263283524c132f3a7f" ]; then
    echo "[*] Patching Bluetooth config update"
    sed -i '29,31d' $FILE  # delete data mibt_config.json
    sed -i '36,39d' $FILE  # delete data bt_config.xml
    sed -i '90d' $FILE     # replace bd_name
    sed -i '93d' $FILE     # replace bt_name
    AMOUNT=$(( $AMOUNT + 1 ))
  fi
  shasum $FILE
fi

FILE=$ROOTFS/etc/init.d/bluetooth
SHA=$(shasum $FILE | awk '{print $1}')
if [ "$SHA" = "f51dabcac09d6815356b85e43aab9884a36965a4" ]; then
  echo "[*] Patching Bluetooth start service"
  sed -i 's/sleep .*/return 0/' $FILE # stop mibt services
  AMOUNT=$(( $AMOUNT + 1 ))
fi
shasum $FILE

FILE=$ROOTFS/etc/init.d/bluetoothd
if [ -f "${FILE}" ]; then
  SHA=$(shasum $FILE | awk '{print $1}')

  echo "[*] Patching Bluetoothd start service"
  sed -i 's;command "$PROG".*;command "$PROG" -n -f $conf_dir/bluetooth/main.conf;' $FILE
  AMOUNT=$(( $AMOUNT + 1 ))
  shasum $FILE
fi

echo "[*] ${AMOUNT} patches applied"

if [ -f "$ROOTFS/etc/init.d/bluetooth" ]; then
  echo "[*] Updating bluealsa binary name and flags for BlueALSA 5.0.0"
  sed -i 's|PROG1=/usr/bin/bluealsa|PROG1=/usr/bin/bluealsad|g' $ROOTFS/etc/init.d/bluetooth
  sed -i 's|^\tbluealsa_get_codecs$|\tCODECS="-c SBC"|g' $ROOTFS/etc/init.d/bluetooth
  sed -i 's/\${CODECS}/-c SBC/g' $ROOTFS/etc/init.d/bluetooth
  sed -i 's/-c SBC -c SBC/-c SBC/g' $ROOTFS/etc/init.d/bluetooth
  sed -i 's/"$PROG2".*/"$PROG2" 00:00:00:00:00:00 -v -D bluetooth -p A2DP --volume=software/' $ROOTFS/etc/init.d/bluetooth
fi

echo "[*] Copying BlueALSA 5.0.0 D-Bus and ALSA configs"
mkdir -p "$ROOTFS/etc/dbus-1/system.d" "$ROOTFS/etc/alsa/conf.d"
cp -vf build-packages/staging/armv7/usr/share/dbus-1/system.d/org.bluealsa.conf "$ROOTFS/etc/dbus-1/system.d/"
cp -vf build-packages/staging/armv7/usr/share/alsa/alsa.conf.d/20-bluealsa.conf "$ROOTFS/etc/alsa/conf.d/"
