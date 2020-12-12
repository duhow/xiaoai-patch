#!/bin/sh

FILE=$ROOTFS/etc/init.d/dlnainit
echo "[*] Disabling DLNA update"
sed -i '/ ota_updata_deicie/s/^/#/' $FILE
shasum $FILE
