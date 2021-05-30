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

# Requirements

This project has been tested on following speakers:

- LX06 - Xiaoai Speaker Pro
- LX01 - Xiaomi Mi AI Speaker Mini 

There are other models that might be compatible, feel free to contribute and provide some help!

- LX05 - Xiaoai Speaker Play
- L09G - Xiaomi Mi Smart Speaker
- Xiaomi Mi AI Speaker 2 Gen

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

# DISCLAIMER
YOU are responsible for any use or damage this software may cause. This repo and its content is intended for educational purposes only. Use at your own risk.