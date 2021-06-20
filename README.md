# Introduction

This repo contains custom scripts and patches, to make a custom rootfs image free of propietary software, and installing open source programs.  
The main purpose of this toolset is to have your DIY Alexa-like speaker, with lots of integrations for music and automation.

By using [MPD], [Snapcast], [Shairport-Sync], [Upmpdcli] you can make your speaker a full media player compatible with multiple cast protocols,
and also have a voice assistant powered by [Porcupine] and [Vosk] that can interact with your [Home Assistant].  
Everything powered by open source software!

[MPD]: https://www.musicpd.org/
[Snapcast]: https://github.com/badaix/snapcast
[Shairport-Sync]: https://github.com/mikebrady/shairport-sync
[Upmpdcli]: https://www.lesbonscomptes.com/upmpdcli/
[Porcupine]: https://github.com/Picovoice/porcupine
[Vosk]: https://alphacephei.com/vosk/
[Home Assistant]: https://www.home-assistant.io/

# Warning

(!) Looks like some new speakers or firmware upgrades change the rootfs partition and include a DER certificate to verify the system.
This **may block** any changes on non-signed squashfs. **Recommended to NOT flash**, you may have an invalid rootfs and potentially lock yourself!
You can check this by running `binwalk` if it contains a Certificate entry:

```
DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             Squashfs filesystem, little endian, version 4.0, compression:xz, size: 32240378 bytes, 2430 inodes, blocksize: 262144 bytes, created: 2021-04-28 06:34:34
32243716      0x1EC0004       Certificate in DER format (x509 v3), header length: 4, sequence length: 830
```

# Requirements

This project has been tested on following speakers:

- LX06 - Xiaoai Speaker Pro
- LX01 - Xiaomi Mi AI Speaker Mini 

There are other models that might be compatible, feel free to contribute and provide some help!

- LX05 - Xiaoai Speaker Play
- L09G - Xiaomi Mi Smart Speaker (Global, Google Assistant)
- L09A - Xiaoai Speaker Art (China)
- L15A - Xiaomi Mi AI Speaker 2 Gen
- MDZ-25-DT - Xiaomi Mi AI Speaker 1 Gen (?)

You will also need a computer with Linux and:

```
- squashfs-tools, provides unsquashfs and mksquashfs
- make
- Docker
```

# Usage

Get a copy of your `rootfs` filesystem from your speaker. It can also be from a system upgrade file.
It should be something similar as this:

```
nc -vlp 8888 > $HOME/backup-image
# -----
dd if=/dev/mtd4 of=/tmp/image
nc $IP_ADDR 8888 < /tmp/image
```

Since the speakers filesystem is in `squashfs` format, we have to reflash it to add the new applications and patches.
There are three steps to perform this: **extract, patch, build**.

Optionally but recommended, prepare the packages you want to install by editing the [packages.sh] script.

[packages.sh]: https://github.com/duhow/xiaoai-patch/blob/master/packages.sh#L657

Build the docker image and run it to build all the packages. Probably it will take more than an hour.  
**NOTE:** Run the **build packages.sh** process with Docker, since the package build performs some patching to the system, otherwise it could harm your GNU/Linux installation.

```
docker build -t xiaoai-patch - < Dockerfile-packages
docker run -it -v $PWD:/xiaoai xiaoai-patch
```

You can now run the commands to prepare the new image.

```
sudo make clean
sudo make extract FILE=image-mtd4
sudo make patch
sudo make build
```

**NOTE:** Ensure the image format is correct, by comparing the original and new images. Use `file` or other commands to check info.

After you have the new image ready, send it to the speaker, and **flash the not-in-use** `rootfs` partition, boot it and test.

# Unbricking

You should have some wires soldered to the board to perform TTL in case it is required.  
As long as you perform steps as described and not flashing content in wrong partitions, you can reverse failed boot with Uboot safely.

In order to enable Uboot menu, check in the environment partition that you have the setting `bootdelay=3`.  
If is set to `bootdelay=0` then Uboot will continue normal boot process and you won't be able to stop it unless you get into fastboot or recovery mode. (?)  
In most cases, binary program is `fw_setenv` or `fw_env` and data is set into first partition as string.

Ensure you can access Uboot before writing changes, it is your rescue!

```
Hit any key to stop autoboot:  0
```

# DISCLAIMER
YOU are responsible for any use or damage this software may cause. This repo and its content is intended for educational purposes only. Use at your own risk.
