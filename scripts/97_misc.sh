#!/bin/sh

echo "ntpd -q -p pool.ntp.org" > squashfs-root/etc/rc.local
echo "show_led 0" >> squashfs-root/etc/rc.local

rm -f squashfs-root/etc/localtime
ln -s squashfs-root/usr/share/zoneinfo/CET squashfs-root/etc/localtime

