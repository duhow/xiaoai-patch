# Install Guide

- author: @danielk117

This instruction is for a new LX06, bought in late 2021.
Xiaomi did some things to make it hard to get access. Just the serial connection isn't working me.
So I have found an another solution using the micro usb port on the board.
A serial connection is helpful but not needed!

The latest revision of the speaker has some different chips on its board (i.e. wifi).
So in my case the speaker doesn't work properbly when using an older firmware (before 1.74.x).
Furthermore an older firmware doesn't remove the new magic password generation for root.
So I'm using a 1.74.10 for the follwing steps.

I'm using the Windows versions of the "Amlogic Update Tool" and the "WinCap" driver.
There seems to be a version of the update tool for linux, but I don't know where to get a linux driver and if it is working.

## prepare

- download "USB Burning Tool" driver and "Amlogic Update Tool", install the driver
  - http://openlinux.amlogic.com:8000/download/A113/Tool/windows/ (the Burning tool includes the driver and installs it)
  - http://openlinux.amlogic.com:8000/download/A113/Tool/flash-tool-v4.7/flash-tool/tools/windows/ (download all files in the directory)

- open the speaker (loosen the 6 screws under the rubber at the bottom, put the cap off and take the 2 cables out of the holder)

- try to push the inner part upwards until you see the board (be careful, as the power and aux jacks are still screwed to the case)

- connect a cable to the micro usb and your computer

- power on -> when windows plays a sound (or 2 seconds after power on) -> run `update.exe identify`
  - if you don't see `firmware version ...` then it wasn't successful and you need to try it again

```
> update.exe identify
AmlUsbIdentifyHost
This firmware version is 0-7-0-16-0-0-0-0
```

## backup

- (optional, but recommended) restore uboot access
  - when using serial connection, you aren't able the interrupt the autoboot of uboot. this is caused by the bootdelay which is setted to 0.
  - I setted it to 30, because in my case, this aren't 30 seconds -> it counts really fast, so 30 are aproxomittly 3-4 seconds.
```
> update.exe bulkcmd "setenv bootdelay 30"
AmlUsbBulkCmd[setenv bootdelay 30]
> update.exe bulkcmd "saveenv"
AmlUsbBulkCmd[setenv bootdelay 30]
```

- dump partitions (for backup)
  - the update tool doesn't show any output from the speaker, so without serial connection,
  we dont see stdout/stderr and we can't get the real size of the partitions.
  so we assume a size of 1GB (1073741824 Bytes -> 0x40000000)
    - the dump stops at the real end of the partition
    - if you have a serial connection, then run `mtdparts` and calculate the real sizes
  - the last argument of `update.exe mread` is the path on your local machine
  - run this for `boot0`, `system0` and `data`:

```
> update.exe mread store boot0 normal 0x40000000 boot0.dump
AmlUsbBulkCmd[upload store boot1 normal 0x40000000]
Want read 65536 bytes, actual len 0
AmlReadMedia failed
ERR: ReadMediaFile failed!

> update.exe mread store system0 normal 0x40000000 system0.dump
AmlUsbBulkCmd[upload store system0 normal 0x40000000]
Want read 65536 bytes, actual len 0
AmlReadMedia failed
ERR: ReadMediaFile failed!

> update.exe mread store data normal 0x40000000 data.dump
AmlUsbBulkCmd[upload store data normal 0x40000000]
Want read 65536 bytes, actual len 0
AmlReadMedia failed
ERR: ReadMediaFile failed!
```

- restart speaker and set it up using the Xiaomi Home app
  (wifi access -> for me, only the official app is able to set all the config files correct, otherwise you need to it over serial connection)
  - choose speaker -> Speaker Pro -> enter wifi credentials -> connect to local AP from Speaker `xiaomi-wifispealer-lx06...`
  - turn off the speaker when setting in the app is done

## create/prepare image

### if you want to use `duhow/xiaoai-patch`
- create a img file using `binwalk`
- follow the main instructions from the readme
  - build the docker and install packages
  - extract and patch (edit the `squashfs-root/etc/shadow` file before building an image, otherwise you need calculate your root password using the serial number...)
  - build a firmware
- flash it

### otherwise (the manual way, credits goes to http://javabin.cn/2021/xiaoai_fm.html)
- download http://cdn.cnbj1.fds.api.mi-img.com/xiaoqiang/rom/lx06/mico_firmware_9c712_1.74.10.bin
- `binwalk -e mico_firmware_9c712_1.74.10.bin`
- `unsquashfs -dest unsquashed_image m5.img`
- (optional) modify `unsquashed_image/etc/inittab` file and change `ttyS0::askfirst:/bin/login` to `ttyS0::askfirst:/bin/ash --login` to restore root access without password over serial connection
- set a new root password in `unsquashed_image/etc/shadow`
  - generate the hash of a password using `openssl passwd -1 -salt 'N0Iz0LLs' 'mysuperpassword'` -> `$1$N0Iz0LLs$8bU0h3Y9Imcgs4r.Kca0C1`
  - replace the hash between the first two colons -> `root:$1$N0Iz0LLs$8bU0h3Y9Imcgs4r.Kca0C1:18128:0:99999:7:::`
- modify `unsquashed_image/etc/rc.local` and add
  ```
  [ -d /data/dropbear ] || mkdir /data/dropbear
  [ -s /data/dropbear/rsa.key ] || dropbearkey -t rsa -s 1024 -f /data/dropbear/rsa.key &> /dev/null
  /usr/sbin/dropbear -E -P /var/run/dropbear.pid -r /data/dropbear/rsa.key > /tmp/ssh.log
  ```
- remove or comment out the line `* 3 * * * /bin/ota slient # check ota` in `unsquashed_image/etc/crontabs/root` to deativate the OTA update
- build an image using `mksquashfs unsquashed_image my_prepared_image.img -b 131072 -comp xz -no-xattrs`
- `my_prepared_image.img` should be ready for flashing


## flash

- power on -> when windows plays a sound (or 2 seconds after power on) -> run `update.exe identify`

- for me, `boot1` and `system1` are empty on a new speaker, so i flashed my `boot0` dump to `boot1` and my prepared image to `system1`

```
> update.exe partition boot1 boot0.dump
file size is 0x600000
AmlUsbTplCmd = download store boot1 normal 0x600000 rettemp = 1 buffer = download store boot1 normal 0x600000
AmlUsbReadStatus retusb = 1
Downloading....
[update]:Cost time 1Sec
[update]:Transfer size 0x600000B(6MB)
AmlUsbBulkCmd[download get_status]
[update]:mwrite success
```
```
> update.exe partition system1 my_prepared_image.img
file size is 0x23bf000
AmlUsbTplCmd = download store system1 normal 0x23bf000 rettemp = 1 buffer = download store system1 normal 0x23bf000
AmlUsbReadStatus retusb = 1
Downloading....
[update]:Cost time 11Sec
[update]:Transfer size 0x23bf000B(35MB)
AmlUsbBulkCmd[download get_status]
[update]:mwrite success
```

- flash `system0` partition
  - if you want to patch the installed firmware on your speaker (the factory installed version might be newer than the one we try to flash),
  then skip flashing the `system0` and set `/usr/bin/fw_env -s boot_part boot1`,
  follow the next step and then get an copy of `mtd4`, i.e. by `dd if=/dev/mtd4 of=/tmp/system0.img` and `scp` for transfering to your computer

```
> update.exe partition system0 my_prepared_image.img
file size is 0x23bf000
AmlUsbTplCmd = download store system0 normal 0x23bf000 rettemp = 1 buffer = download store system0 normal 0x23bf000
AmlUsbReadStatus retusb = 1
Downloading....
[update]:Cost time 10Sec
[update]:Transfer size 0x23bf000B(35MB)
AmlUsbBulkCmd[download get_status]
[update]:mwrite success
```

- restart speaker, search it in your network and try connect to ssh (using root and the password you prepared in the image)

```
  _____  _              __     __ __  ___  ___
 |     ||_| ___  ___   |  |   |  |  ||   ||  _|
 | | | || ||  _|| . |  |  |__ |-   -|| | || . |
 |_|_|_||_||___||___|  |_____||__|__||___||___|
------------------------------------------------

      ROM Type:release / Ver:1.74.10
------------------------------------------------
root@LX06-0239:~#
```

- remove usb cable and reassemble your speaker

- done 😄
