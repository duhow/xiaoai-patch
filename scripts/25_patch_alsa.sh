#!/bin/sh

FILE=$ROOTFS/etc/asound.conf
echo "[*] Disabling DTS Audio"

sed -i "s/slave.pcm dtsaudio/slave.pcm dmixer/" $FILE
shasum $FILE
