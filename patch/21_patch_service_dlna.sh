#!/bin/sh

echo "[*] Disabling DLNA update"
sed -i '/ ota_updata_deicie/s/^/#/' $ROOTFS/etc/init.d/dlnainit
