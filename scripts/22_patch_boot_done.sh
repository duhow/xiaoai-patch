#!/bin/sh

FILE=$ROOTFS/etc/init.d/done
SHA=$(shasum $FILE | awk '{print $1}')
#if [ "$SHA" = "a38a31b89b5fa782d31984f9b6fb25d86ee47181" ] ; then
#  echo "[*] Patching boot led"
#fi

echo "[*] Updating boot led and update NTP time"
LED=13
sed -i "/set leds/a /bin/show_led ${LED}\n\tsleep 2\n\t/bin/shut_led ${LED}\n\tntpd -q -p pool.ntp.org &" $FILE

shasum $FILE
