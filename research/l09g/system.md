## Input

Buttons: `/dev/input/event0`

| event | description |
|-------|-------------|
| `KEY_VOLUMEDOWN` | Vol Down |
| `KEY_MENU` | Play/pause |
| `KEY_POWER` | Microphone mute |
| `KEY_VOLUMEUP` | Vol Up |
| `KEY_RIGHT` | Vol Down + Vol Up |

**NOTE**: `KEY_POWER` acts as a toggle, and will keep un/active until pressed again.
This will eventually also trigger another event at `/dev/input/event2`: `KEY_MICMUTE`

## Chroot

```bash
# send file
# ncat -vlp 8888 < file.tar.gz

# kill Google Home Assistant
ps | grep -e '^chrome' | cut -d' ' -f5 | xargs kill -9

mkdir -p /new && cd /new
curl -so- 192.168.10.205:8888 | gzip -d | tar xvf - 

for N in sh ln ls ps mkdir rm cat grep date find hostname strings zcat netstat nc; do ln -s busybox bin/$N; done

mkdir -p proc && mount -t proc /proc proc/
mkdir -p sys && mount -t sysfs /sys sys/
mkdir -p dev && mount -o bind /dev dev/

chroot .
```

## Boot

System is prepared to allow A/B boot, but checking on current `/proc/cmdline`, we are using `normal` boot (single part).
`androidboot.slot_suffix=normal`

`/sbin/mount_partitions.sh`

```bash
CMDLINE=$(busybox cat /proc/cmdline)
TEMP=${CMDLINE#*slot_suffix=}
SYSTEM_SELECT=`echo ${TEMP% * } | busybox cut -d " " -f 1`
case "${SYSTEM_SELECT}" in
"_b")
echo "mount b partition"
/sbin/ubiattach /dev/ubi_ctrl -m 6 -d 6
busybox mount -t ubifs /dev/ubi6_0 /system -rw
/sbin/ubiattach /dev/ubi_ctrl -m 7 -d 7
busybox mount -t ubifs /dev/ubi7_0 /factory -rw
/sbin/ubiattach /dev/ubi_ctrl -m 8 -d 8
busybox mount -t ubifs /dev/ubi8_0 /cache -rw
;;
"_a")
echo "mount a partition"
/sbin/ubiattach /dev/ubi_ctrl -m 5 -d 5
busybox mount -t ubifs /dev/ubi5_0 /system -rw
/sbin/ubiattach /dev/ubi_ctrl -m 7 -d 7
busybox mount -t ubifs /dev/ubi7_0 /factory -rw
/sbin/ubiattach /dev/ubi_ctrl -m 8 -d 8
busybox mount -t ubifs /dev/ubi8_0 /cache -rw
;;
"normal")
echo "mount normal partition"
/sbin/ubiattach /dev/ubi_ctrl -m 6 -d 6 -b 1
busybox mount -t ubifs /dev/ubi6_0 /factory -rw
/sbin/ubiattach /dev/ubi_ctrl -m 7 -d 7
busybox mount -t ubifs /dev/ubi7_0 /cache -rw
;;
*)
echo "else mount normal partition"
/sbin/ubiattach /dev/ubi_ctrl -m 6 -d 6 -b 1
busybox mount -t ubifs /dev/ubi6_0 /factory -rw
/sbin/ubiattach /dev/ubi_ctrl -m 7 -d 7
busybox mount -t ubifs /dev/ubi7_0 /cache -rw
;;
esac 
```

## Wifi

NOTE: script looks for `ctrl_interface` text, otherwise it replaces it.

```
~ # cat /data/wifi/wpa_supplicant.conf
ctrl_interface=/data/wifi
update_config=1
country=ES

network={
        ssid="your_ssid_here"
        scan_ssid=1
        psk=HASH_PWD
        proto=RSN
        key_mgmt=WPA-PSK
        pairwise=CCMP
        frequency=5180
}
```

```
~ # cat /sbin/force_bootup_sequence.sh
touch /tmp/play_bootup
chown chrome:chrome /tmp/play_bootup


~ # cat /sbin/boot_complete.sh
sleep 30
if /bin/exists /tmp/cast-control;then
    echo "already exist /tmp/cast-control"
else
    echo "no exist /tmp/cast-control, restart cast_shell"
    /chrome/cast_cli stop cast
    start cast_installer
fi
rm /data/chrome/.org.chromium.*
setprop boot.complete 1

~ # getprop boot.complete
1

~ # cat /sbin/mute_check_bootup.sh
#!/bin/sh
MUTE_CHECK_STATE="/data/chrome/mic_muted_bootup"
if /bin/exists ${MUTE_CHECK_STATE}; then
echo "mic enter mute mode"
i2cset -f -y 1 0x1f 0x03 0x7f
sleep 1
i2cset -f -y 1 0x1f 0x03 0xff
fi # exists
```
