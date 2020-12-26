#!/bin/sh

FILE=$ROOTFS/etc/config/system
TZ="CET"
echo "[*] Updating timezone to ${TZ}"

sed -i "/option zonename/s;PRC;${TZ};" $FILE
shasum $FILE
