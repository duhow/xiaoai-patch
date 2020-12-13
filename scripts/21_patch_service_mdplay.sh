#!/bin/sh

FILE=$ROOTFS/etc/init.d/mdplay
SHA=$(shasum $FILE | awk '{print $1}')
echo "[*] Disabling auto-start of mdplay service"
sed -i '/procd_open_instance/i     [ -x /data/enable_mdplay ] || return 0' $FILE

shasum $FILE
