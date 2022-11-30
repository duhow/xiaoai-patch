#!/bin/sh


AMOUNT=0
FILE=$ROOTFS/etc/init.d/check_mac
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

FILE=$ROOTFS/etc/init.d/bluetooth
SHA=$(shasum $FILE | awk '{print $1}')
if [ "$SHA" = "f51dabcac09d6815356b85e43aab9884a36965a4" ]; then
  echo "[*] Patching Bluetooth start service"
  sed -i 's/sleep .*/return 0/' $FILE # stop mibt services

  # new bluealsa params, fix start
  sed -i 's/"$PROG2".*/"$PROG2" 00:00:00:00:00:00 -v -D bluetooth --profile-a2dp/' $FILE
  AMOUNT=$(( $AMOUNT + 1 ))
fi
shasum $FILE

FILE=$ROOTFS/etc/init.d/bluetoothd
if [ -f "${FILE}" ]; then
  SHA=$(shasum $FILE | awk '{print $1}')

  echo "[*] Patching Bluetoothd start service"
  # add parameter to load config from writable flash, not readonly memory
  # so this way user can customize bluetooth name and params
  sed -i 's;command "$PROG".*;command "$PROG" -n -f $conf_dir/bluetooth/main.conf;' $FILE
  AMOUNT=$(( $AMOUNT + 1 ))
fi

shasum $FILE

echo "[*] ${AMOUNT} patches applied"
