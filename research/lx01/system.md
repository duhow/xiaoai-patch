# LX01 - Xiaomi Mi Smart Speaker Mini

## Partitions

```
# cat /proc/partitions 
major minor  #blocks  name

  93        0       1024 nanda # env
  93        8       6144 nandb # kernel1
  93       16      32768 nandc # rootfs1
  93       24       6144 nandd # kernel2
  93       32      32768 nande # rootfs2
  93       40       1024 nandf # misc
  93       48       1024 nandg # private
  93       56       1024 nandh # crashlog
  93       64      14336 nandi # UDISK

kernel1: uImage header, header size: 64 bytes, header CRC: 0x3C29ED9B, created: 1970-01-01 00:00:00,
         image size: 3362120 bytes, Data Address: 0x40008000, Entry Point: 0x40008000,
         data CRC: 0x2BC8C753, OS: Linux, CPU: ARM, image type: OS Kernel Image,
         compression type: none, image name: "ARM OpenWrt Linux-3.4.39"

rootfs2: Squashfs filesystem, little endian, version 4.0, compression:xz,
         size: 22480258 bytes, 1526 inodes, blocksize: 262144 bytes, created: 2018-06-14 02:25:53

UDISK:   Linux EXT filesystem, rev 1.0, ext4 filesystem data
```

## Uboot environment data

```
# strings /dev/nanda

boot_fastboot=fastboot
boot_first=fatload sunxi_flash kernel1 43800000 uImage;bootm 43800000
boot_second=fatload sunxi_flash kernel2 43800000 uImage;bootm 43800000
bootcmd=run setargs_second boot_second
bootdelay=3
console=ttyS0,115200
ethact=usb_ether
fastboot_key_value_max=0x8
fastboot_key_value_min=0x2
first_root=/dev/nandc
init=/sbin/init
loglevel=8
nor_root=/dev/mtdblock4
partitions=env@nanda:kernel1@nandb:rootfs1@nandc:kernel2@nandd:rootfs2@nande:misc@nandf:private@nandg:crashlog@nandh:UDISK@nandi
recovery_key_value_max=0x13
recovery_key_value_min=0x10
second_root=/dev/nande
setargs_first=setenv bootargs console=${console} root=${first_root} rootwait init=${init} ion_cma_list="8m,32m,64m,128m,256m" loglevel=${loglevel} partitions=${partitions}
setargs_nor=setenv bootargs console=${console} root=${nor_root} rootwait init=${init} ion_cma_list="8m,32m,64m,128m,256m"loglevel=${loglevel} partitions=${partitions}
setargs_second=setenv bootargs console=${console} root=${second_root} rootwait init=${init} ion_cma_list="8m,32m,64m,128m,256m" loglevel=${loglevel} partitions=${partitions}
stderr=serial
stdin=serial
stdout=serial
sunxi_hardware=sun8i
sunxi_serial=2737885xxxxxxxxxxxxx
usbnet_devaddr=ee:6a:6c:29:6a:29
usbnet_hostaddr=6e:6a:6c:29:6a:29
```

## misc data

Stores data to indicate the boot partition. Data is plain-binary stored.
Each section allows to input **32 bytes**. Values are stored as strings, no hex/bin encoded.

| Name | Write short code | Description |
|------|------------|-------------|
| command | `-c` | Used to trigger conditions while performing upgrades. (`efex, boot-recovery`) |
| status | `-s` | unknown. |
| version | `-v` | unknown. |
| count | `-n` | unknown. |
| boot_status | `-b` | Self-explanatory. |
| sys1_failed | `-a` | Sets rootfs1 as invalid, forces to boot to rootfs2. |
| sys2_failed | `-d`  | Sets rootfs2 as invalid, forces to boot to rootfs1. |
| boot_rootfs | `-r` | Indicates what rootfs is running at the moment. |
| ota_reboot | `-o` | Indicates if reboot was triggered by OTA. If true, will start the **other** partition than the `last_success`. |
| last_success | `-l` | Used to change partition to boot. Value set in here will be the `boot_rootfs` to boot on next reboot. |
| silent :new: | `-e` | Used to check if boot silent? |

Programs `read_misc` and `write_misc` allow to interact with the misc partition `nandf`.
**Required** to have ENV `partitions` defined. SSH sessions don't share this info, while console does.

```bash
export `strings /proc/1/environ | grep partitions`
```

Command `read_misc` allows to get all values or specified name.

```
root@LX01:~# read_misc
command: FACTORY
status:  0
version: 00000
count:   0
boot_status:  1
sys1_failed:  0
sys2_failed:  0
boot_rootfs:  1
ota_reboot:   0
last_success: 1

root@LX01:~# read_misc last_succes
1
```

Command `write_misc` allows to change the values. See table reference above.

```
# Change boot from rootfs2 to rootfs1

root@LX01:~# ls -l /dev/root
lrwxrwxrwx    1 root     root            10 Jul  3 12:35 /dev/root -> /dev/nande
root@LX01:~# read_misc boot_rootfs
1
root@LX01:~# read_misc last_success
1
root@LX01:~# write_misc -l 0
root@LX01:~# read_misc last_success
0
```

## switch boot

To switch boot partitions, let's assume the following:

```
boot_status:  1
sys1_failed:  0
sys2_failed:  0
boot_rootfs:  0
ota_reboot:   1
last_success: 1
```

This currently is booting `nandc` / `rootfs1` (because `boot_rootfs: 0`) as part of an OTA update.
If we want to switch to the other partition `nande` / `rootfs2`, we can either:

- set `ota_reboot: 0` to mark as "failed", since `last_success` is still `rootfs2`
- set `last_success: 0` from current `boot_rootfs: 0` and keep enabled `ota_reboot: 1`.


## private data

Partition `nandg` contains string data splitted by newline `0x0a`.

```
bt=40:31:3C:00:00:00
mac=40:31:3C:00:00:00
key=IePxJ9XXXXXXXXXX
did=108000000
hid=1000
ver=1
fid=xpndixxxxxxx
sn=18566/00000000
```

## LED

A single `WS2812` RGB LED.

```
echo 50 50 50 > /proc/ws2812/rgb0
```

