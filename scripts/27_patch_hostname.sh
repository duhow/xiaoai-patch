#!/bin/sh

FILE=$ROOTFS/etc/init.d/boot
echo "[*] Updating hostname"

sed -i -e '/ifconfig lo/a\ # update hostname \n SN=$(echo -n `uci -c /data/etc get binfo.binfo.sn` | tail -c -4)\n MODEL=$(uci -c /usr/share/mico get version.version.HARDWARE)\n echo "$MODEL-$SN" > /proc/sys/kernel/hostname' $FILE

