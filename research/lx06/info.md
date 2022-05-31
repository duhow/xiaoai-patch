# Info

Tested with firmware 1.58.15

# Images and partitions

```
root@mico:~# cat /proc/mtd
dev:    size   erasesize  name
mtd0: 00200000 00020000 "bootloader"
mtd1: 00800000 00020000 "tpl"
mtd2: 00600000 00020000 "boot0"
mtd3: 00600000 00020000 "boot1"
mtd4: 02820000 00020000 "system0"
mtd5: 02800000 00020000 "system1"
mtd6: 013e0000 00020000 "data"
```
| block | size | description |
|-------|------|-------------|
| mtd0 | 258048 | uboot |
| mtd1 | 8388608 | tpl (?) |
| mtd2 | 6291456 | kernel boot image 1 |
| mtd3 | 6291456 | kernel boot image 2 (empty on first boot) |
| mtd4 | 41943040 | rootfs partition 1 squashfs |
| mtd5 | 41943040 | rootfs partition 2 squashfs (empty on first boot) |
| mtd6 | 20709376 | ubifs data partition, 13.3MB to use |

```
Target File:   /lx06/mtd1
MD5 Checksum:  e78660e77c10a2a4a6bb5b63ed32b4b9

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
219040        0x357A0         Android bootimg, kernel size: 1280131328 bytes, kernel addr: 0x55434553, ramdisk size: 1094713377 bytes, ramdisk addr: 0x61004C4D, product name: ""
219219        0x35853         Unix path: /amlogic/board/axg/secureboot/secureboot.c
223632        0x36990         SHA256 hash constants, little endian
2316192       0x2357A0        Android bootimg, kernel size: 1280131328 bytes, kernel addr: 0x55434553, ramdisk size: 1094713377 bytes, ramdisk addr: 0x61004C4D, product name: ""
2316371       0x235853        Unix path: /amlogic/board/axg/secureboot/secureboot.c
2320784       0x236990        SHA256 hash constants, little endian
4413344       0x4357A0        Android bootimg, kernel size: 1280131328 bytes, kernel addr: 0x55434553, ramdisk size: 1094713377 bytes, ramdisk addr: 0x61004C4D, product name: ""
4413523       0x435853        Unix path: /amlogic/board/axg/secureboot/secureboot.c
4417936       0x436990        SHA256 hash constants, little endian
6510496       0x6357A0        Android bootimg, kernel size: 1280131328 bytes, kernel addr: 0x55434553, ramdisk size: 1094713377 bytes, ramdisk addr: 0x61004C4D, product name: ""
6510675       0x635853        Unix path: /amlogic/board/axg/secureboot/secureboot.c
6515088       0x636990        SHA256 hash constants, little endian

Target File:   /lx06/mtd2
MD5 Checksum:  e10271e03f213271dc8d1af185550f1f

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             Android bootimg, kernel size: 3718436 bytes, kernel addr: 0x1080000, ramdisk size: 1430686 bytes, ramdisk addr: 0x1000000, product name: ""
2048          0x800           gzip compressed data, maximum compression, from Unix, NULL date (1970-01-01 00:00:00)
3721216       0x38C800        gzip compressed data, maximum compression, from Unix, NULL date (1970-01-01 00:00:00)
5173167       0x4EEFAF        eCos RTOS string reference: "ecos"
5173218       0x4EEFE2        eCos RTOS string reference: "ecos_memory"

Target File:   /lx06/mtd4
MD5 Checksum:  4a77b11dadef5a20a8a26bc8df14a68d

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             Squashfs filesystem, little endian, version 4.0, compression:xz, size: 32345147 bytes, 1810 inodes, blocksize: 131072 bytes, created: 2019-12-25 03:18:35

Target File:   /lx06/mtd6
MD5 Checksum:  d8bb66ac48fc599e219d8bb6eb82dc38

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             UBI erase count header, version: 1, EC: 0x2, VID header offset: 0x800, data offset: 0x1000
```

# IR (infrared)

```
root@mico:~# cat /sys/ir_rx_power/rx_power
ir rx power off
root@mico:~# echo on > /sys/ir_rx_power/rx_power
root@mico:~# cat /sys/ir_rx_power/rx_power
ir rx power on
root@mico:~# dmesg | tail
[ 1833.769868@2] [ir_rx] ir rx power on.
[ 1834.000393@0] [ir_rx] receive -111 datas.
[ 1851.808411@0] [ir_rx] receive -111 datas.
[ 1853.052437@0] [ir_rx] receive -111 datas.
[ 1853.988401@0] [ir_rx] receive -111 datas.
[ 1854.716435@0] [ir_rx] receive -111 datas.
[ 1866.293905@0] [ir_rx] ir rx power off.
[ 1890.609216@2] [ir_rx] ir rx power on.
[ 1890.736406@0] [ir_rx] useless datas 8 .
[ 1902.784395@0] [ir_rx] receive -111 datas.

root@mico:/# cat /sys/kernel/debug/gpio
gpiochip0: GPIOs 0-14, parent: platform/pinctrl@ff800014, aobus-banks:
 gpio-5   (                    |?                   ) out lo
 gpio-6   (                    |ir_rx               ) in  hi IRQ
 gpio-7   (                    |gpio-ir-tx          ) out lo

gpiochip1: GPIOs 15-100, parent: platform/pinctrl@ff634480, periphs-banks:
 gpio-18  (                    |aw20054-hwen-pin    ) out hi
 gpio-20  (                    |gpio-ir-rx-power    ) out lo
 gpio-21  (                    |codec_pdn           ) out hi
 gpio-59  (                    |sysfs               ) in  hi
 gpio-61  (                    |auxin_det           ) in  lo IRQ
 gpio-69  (                    |sdio_wifi           ) out hi
 gpio-78  (                    |sysfs               ) out hi
 gpio-79  (                    |sdio_wifi           ) in  hi
 gpio-83  (                    |bt_rfkill           ) in  hi
```

Send IR commands

- Uses IR Raw protocol without signs.
- Pairs of numbers, first is positive (ON), second is negative (OFF).

```
root@mico:~# echo 9003,4494,566,1692,562,1691,566,1692 > /sys/ir_tx_gpio/ir_data
```

- Use [irgen](https://github.com/elupus/irgen) to convert IR codes to `raw`. (compatible with Broadlink)
- Use [IrScrutinizer](https://github.com/bengtmartensson/IrScrutinizer) for advanced analysis of IR codes.
- Use [irplus LAN](https://play.google.com/store/apps/details?id=net.binarymode.android.irpluslan) 📱 to send IR Raw commands. 📺 Use URL: `http://${SPEAKER_IP}:8766/cgi-bin/ir.cgi`
- Pending: Create LIRC server implementing something like [broadlink-bridge](https://github.com/lbschenkel/broadlink-bridge)

```bash
CODE=JgAKASkOJw8NKg4pDikOKQ4oDygPKA4pDikO8icQJxANKQ4pDygoDycQJxAnDygPJxAn2CkOKQ4NKg4pDikOKQ0qJw.....

irgen -i broadlink_base64 -d ${CODE} -o raw | tr ' ' '\n' | cut -c 2- | cut -d '.' -f1 | tr '\n' ','
1249,426,1188,457,396,1279,426,1249,426,1249,426,1249,426,1218,457,1218,457,1218,426,1249,426,1249
```

Remove module and manually use GPIO

```
root@mico:~# rmmod gpio_ir_rx
root@mico:~# echo 20 > /sys/class/gpio/export
root@mico:~# echo 6 > /sys/class/gpio/export

# power on rx
root@mico:/sys/class/gpio# echo 0 > /sys/class/gpio/gpio20/value
root@mico:~# ls -l /sys/class/gpio/


root@mico:~# cat /sys/kernel/debug/gpio
gpiochip0: GPIOs 0-14, parent: platform/pinctrl@ff800014, aobus-banks:
 gpio-5   (                    |?                   ) out lo
 gpio-6   (                    |sysfs               ) in  hi
 gpio-7   (                    |gpio-ir-tx          ) out lo

gpiochip1: GPIOs 15-100, parent: platform/pinctrl@ff634480, periphs-banks:
 gpio-18  (                    |aw20054-hwen-pin    ) out hi
 gpio-20  (                    |sysfs               ) out hi
 gpio-21  (                    |codec_pdn           ) out hi
 gpio-59  (                    |sysfs               ) in  hi
 gpio-61  (                    |auxin_det           ) in  lo IRQ
 gpio-69  (                    |sdio_wifi           ) out hi
 gpio-78  (                    |sysfs               ) out hi
 gpio-79  (                    |sdio_wifi           ) in  hi
 gpio-83  (                    |bt_rfkill           ) in  hi
```

# Aux In (jack)

ALSA device is `hw:0,1`.

```
root@mico:/sys/auxin_det# cat status
aux_out  # unplugged
aux_in   # plugged

EV_SW   SW_HEADPHONE_INSERT     1       /dev/input/event1  # plugged

root@mico:~# getevent -p /dev/input/event1
add device 1: /dev/input/event1
  name:     "Xiaomi mico auxiliary port"
  events:
    SW  (0005): 0002
  input props:
    <none>
```

# Button inputs

```
root@mico:~# getevent -p /dev/input/event0 | grep KEY
    KEY (0001): 0066  0072* 0073  008b

EV_KEY  KEY_HOME        1       /dev/input/event0  # mute
EV_KEY  KEY_VOLUMEUP    1       /dev/input/event0  # volume down
EV_KEY  KEY_VOLUMEDOWN  1       /dev/input/event0  # play
EV_KEY  KEY_MENU        1       /dev/input/event0  # volume up
```

# uboot settings

```
fw_env -g boot_part
fw_env -s boot_part boot1
fw_env -p # print

root@mico:~# fw_env -p
[ubootenv] key: [aml_dt]
[ubootenv] value: [xiaomi_lx06_v01]

[ubootenv] key: [baudrate]
[ubootenv] value: [115200]

[ubootenv] key: [board_id]
[ubootenv] value: [1]

[ubootenv] key: [boot_failcnt]
[ubootenv] value: [0]

[ubootenv] key: [boot_failed]
[ubootenv] value: [if itest ${boot_failcnt} == 1; then setenv boot_failcnt 2; setenv boot_part boot1; else if itest ${boot_failcnt} == 2; then setenv boot_failcnt 1; setenv boot_part boot0; else run set_boot_flag;fi;fi;]

[ubootenv] key: [boot_part]
[ubootenv] value: [boot0]

[ubootenv] key: [bootargs]
[ubootenv] value: [rootfstype=ramfs init=/init console=ttyS0,115200 no_console_suspend earlycon=aml_uart,0xff803000 jtag=apao reboot_mode=cold_boot uboot=U-Boot 2015.01 (Dec 25 2019 - 03:56:50)]

[ubootenv] key: [bootcmd]
[ubootenv] value: [run storeboot]

[ubootenv] key: [bootdelay]
[ubootenv] value: [1]

[ubootenv] key: [deviceid]
[ubootenv] value: [23948/000000000]

[ubootenv] key: [dtb_mem_addr]
[ubootenv] value: [0x1000000]

[ubootenv] key: [factory_detect]
[ubootenv] value: [if keyman read deviceid ${loadaddr} str; then echo HAVE SN Code ...; else echo Switch to boot1 system, because of NOT found SN Code ...; setenv boot_failcnt 2; setenv boot_part boot1; fi;]

[ubootenv] key: [fdt_high]
[ubootenv] value: [0x20000000]

[ubootenv] key: [firstboot]
[ubootenv] value: [1]

[ubootenv] key: [identifyWaitTime]
[ubootenv] value: [1000]

[ubootenv] key: [initargs]
[ubootenv] value: [rootfstype=ramfs init=/init console=ttyS0,115200 no_console_suspend earlycon=aml_uart,0xff803000]

[ubootenv] key: [jtag]
[ubootenv] value: [apao]

[ubootenv] key: [loadaddr]
[ubootenv] value: [1080000]

[ubootenv] key: [preboot]
[ubootenv] value: [run storeargs;if test ${reboot_mode} = cold_boot; then run try_auto_burn; fi;]

[ubootenv] key: [product_model]
[ubootenv] value: [lx06]

[ubootenv] key: [reboot_mode]
[ubootenv] value: [cold_boot]

[ubootenv] key: [rpmb_state]
[ubootenv] value: [0]

[ubootenv] key: [set_boot_flag]
[ubootenv] value: [if test ${boot_part} = boot0; then setenv boot_failcnt 1; else setenv boot_failcnt 2; fi;]

[ubootenv] key: [silent_boot]
[ubootenv] value: [0]

[ubootenv] key: [stderr]
[ubootenv] value: [serial]

[ubootenv] key: [stdin]
[ubootenv] value: [serial]

[ubootenv] key: [stdout]
[ubootenv] value: [serial]

[ubootenv] key: [storeargs]
[ubootenv] value: [setenv bootargs ${initargs} jtag=${jtag}; setenv bootargs ${bootargs} reboot_mode=${reboot_mode} uboot=${version};keyman init 0x1234;]

[ubootenv] key: [storeboot]
[ubootenv] value: [if test ${reboot_mode} = cold_boot; then run set_boot_flag; run factory_detect; else run boot_failed; fi; saveenv; if imgread kernel ${boot_part} ${loadaddr}; then bootm ${loadaddr}; fi; reset;]

[ubootenv] key: [try_auto_burn]
[ubootenv] value: [update 500 1000;]

[ubootenv] key: [ubootenv_version]
[ubootenv] value: [1]

[ubootenv] key: [upgrade_step]
[ubootenv] value: [2]

[ubootenv] key: [version]
[ubootenv] value: [U-Boot 2015.01 (Dec 25 2019 - 03:56:50)]
```
