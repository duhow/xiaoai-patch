#!/bin/sh

FILE=$ROOTFS/etc/init.d/dlnainit
SHA=$(shasum $FILE | awk '{print $1}')
echo "[*] Disabling DLNA update"
sed -i '/ ota_updata_deicie/s/^/#/' $FILE

# original OR patched
if [ "$SHA" = "a38a31b89b5fa782d31984f9b6fb25d86ee47181" ] || [ "$SHA" = "8608ac336bd06e3cb0447f8f9cc518229d494acf" ] ; then
echo "[*] Patching DLNA service"
sed -i '40 a     [ -x /data/enable_dlna ] || return 0' $FILE
fi

shasum $FILE

FILE=$ROOTFS/etc/init.d/mitv-disc
SHA=$(shasum $FILE | awk '{print $1}')
if [ "$SHA" = "e33e61db30db3572271a438befb6293ea68d0037" ]; then
echo "[*] Patching MiTV UPNP service"
sed -i '9 a     [ -x /data/enable_dlna ] || return 0' $FILE
fi
