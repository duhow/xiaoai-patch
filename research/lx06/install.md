# L06A/LX06: Install guide

📝 [Old guide version](https://github.com/duhow/xiaoai-patch/blob/04dd4d8b1c38f1ca079cd9723898fa1e6c50ade5/research/lx06/install.md)

## Prerequisites

💾 Download from [latest release](https://github.com/duhow/xiaoai-patch/releases/latest) the file ending with `lx06.tar`.
This file works for both **L06A** and **LX06** models.

Extract `boot.img` and `root.squashfs` in any located folder.

### Windows 10

Kudos to [@danielk117](https://github.com/danielk117) for the guide in Windows!

💾 Download `Amlogic_Flash_Tool_v6.0.0.zip` from https://androidmtk.com/download-amlogic-flash-tool .  
MD5: `74d95ee04931e690a9e39f92bca32b40`

Install the **WorldCup** driver from `drivers` folder of the zip.

The `update.exe` tool is inside the `bin` folder of the dowloaded zip.

### Linux (Ubuntu 24.04)

```sh
# package may have other names in different distros: libusb-compat-0.1
sudo apt install -y libusb-0.1-4
git clone https://github.com/radxa/aml-flash-tool
sudo cp -v aml-flash-tool/tools/_install_/70-persistent-usb-ubuntu14.rules /lib/udev/rules.d/
# for guide compatibility
ln -s update aml-flash-tool/tools/linux-x86/update.exe
```

> [!IMPORTANT]
> Make sure to reboot to apply `udev` changes!

> [!TIP]
> The guide will refer to the command `update` named as `update.exe`, located in `aml-flash-tool/tools/linux-x86`.
> After rebooting, you may temporally update the `$PATH` to easily call your required commands.

```sh
export PATH=$HOME/aml-flash-tool/tools/linux-x86:$PATH
```

## Preparation

Open the speaker by the bottom. Loosen the 6 screws under the rubber at the bottom, put the cap off and take the 2 cables out of the holder.

Try to push the inner part upwards until you see the board.

> [!WARNING]
> Be careful, as the Power and AUX jacks are still screwed to the case. You may unscrew them to get access easily.

Connect a micro USB cable to the speaker USB port, and your computer.

⚠️ **Only in Windows**: After installing the driver for the first time, 🔌 Power on the speaker while having it connected via USB port.
Windows recognizes the device and starts a service, which seems to be needed for using the `update` tool. After it's done, 🔌 power off the speaker.

> [!NOTE]
> Read this first before 🔌 powering on the speaker!

When 🔌 powering on the speaker, in about ~2 seconds, you must run `update.exe identify` (several times), until the firmware version appears in your console.
This will stop the normal booting process and allow you to flash the speaker.

```sh
update.exe identify
# AmlUsbIdentifyHost
# This firmware version is 0-7-0-16-0-0-0-0
```

If you don't see the message, 🔌 power off the speaker, wait a few seconds, and repeat the process again.

> [!TIP]
> You may run a `loop` to quickly trigger this until success.

```sh
# for Linux
while true ; do update identify ; done
```

## Backup

> [!TIP]
> For future recovery purposes, it's highly recommended you set a `bootdelay` to interrupt u-boot (bootloader).

```sh
update.exe bulkcmd "setenv bootdelay 15"
# AmlUsbBulkCmd[setenv bootdelay 15]
# [AmlUsbRom]Inf:bulkInReply success

update.exe bulkcmd "saveenv"
# AmlUsbBulkCmd[saveenv]
# [AmlUsbRom]Inf:bulkInReply success
```

Dump the current partitions for safety and recovery purposes.
Check that the images are received correctly, check file sizes.

```sh
update.exe mread store bootloader normal 0x200000 mtd0.img
update.exe mread store tpl normal 0x800000 mtd1.img
update.exe mread store boot0 normal 0x600000 mtd2.img
update.exe mread store boot1 normal 0x600000 mtd3.img
update.exe mread store system0 normal 0x2820000 mtd4.img
update.exe mread store system1 normal 0x2800000 mtd5.img
update.exe mread store data normal 0x13e0000 mtd6.img

# --- expect this as a response:
# [AmlUsbRom]Inf:bulkInReply success
# [Uploading]OK:<6>MB in <0>Sec
```

## Flash

💾 Locate the `boot.img` and `root.squashfs` files from the firmware downloaded or built.

We will flash both partitions (A/B), note the number `0` and `1` in commands.

> [!TIP]
> Flashing `boot.img` here is only needed to recover a missing/broken boot partition, or to move to a
> known-good kernel build — `xiaoai-patch` does not modify or rebuild the kernel at all, it just ships a
> pre-extracted stock image. If your existing `boot0`/`boot1` already boots fine (you just dumped it in the
> **Backup** step above), you can skip re-flashing it and keep your own — this is often safer. In practice:
> the `boot.img` bundled here is a `Mon Jun 28 02:23:39 2021` kernel build, and some newer LX06 units ship
> with NAND chips (e.g. Foresee/ESMT `FSNS8A001G`) that this older kernel doesn't recognize, causing a boot
> loop — see **Troubleshooting** below.

```sh
update.exe partition boot0 boot.img

update.exe partition boot1 boot.img

# file size is 0x600000
# AmlUsbTplCmd = download store boot1 normal 0x600000 rettemp = 1 buffer = download store boot1 normal 0x600000
# AmlUsbReadStatus retusb = 1
#  Downloading....
# [update]:Cost time 1Sec
# [update]:Transfer size 0x600000B(6MB)
# AmlUsbBulkCmd[download get_status]
# [update]:mwrite success
```

Now flash the firmware system:

```sh
update.exe partition system0 root.squashfs

update.exe partition system1 root.squashfs

# file size is 0x23bf000
# AmlUsbTplCmd = download store system1 normal 0x23bf000 rettemp = 1 buffer = download store system1 normal 0x23bf000
# AmlUsbReadStatus retusb = 1
# Downloading....
# [update]:Cost time 11Sec
# [update]:Transfer size 0x23bf000B(35MB)
# AmlUsbBulkCmd[download get_status]
# [update]:mwrite success
```

That's all! 😄

You may reassemble your speaker.

## Troubleshooting

### Boot loop after flashing `boot.img` on newer LX06 units (Foresee/ESMT FSNS8A001G NAND)

**Symptom:** after flashing the release `boot.img` (step **Flash** above), the speaker boot-loops.
UART console shows:

```
nand: Unknown FSNS8A001G
...
No NAND device found!!!
...
nand init failed:-6
```
followed by a `reboot`.

**Cause:** the release `boot.img` (kernel build `Mon Jun 28 02:23:39 2021`, banner
`jenkins@a69f86dfe04f`) does not recognize a Foresee/ESMT `FSNS8A001G` NAND chip (manufacturer ID
`0xCD`, chip ID `0xF1`) found on some newer LX06 units. See the tip in the **Flash** section above —
in general you don't need to flash `boot.img` at all if your own `boot0`/`boot1` already works.

**Fix:** flash your own factory `mtd2.img` (dumped as `boot0` in the **Backup** step above) back
into `boot0` — and `mtd3.img` into `boot1` — instead of the release `boot.img`:

```sh
update.exe partition boot0 mtd2.img
```

Confirm over UART that the unit boots normally before repeating for `boot1`. No rebuild is
required — it is the exact image that was already running on this unit.

> [!TIP]
> If you did not keep a factory backup before flashing and hit this boot loop, check
> [duhow/xiaoai-patch](https://github.com/duhow/xiaoai-patch) for a possible updated release
> `boot.img` or open an issue with your NAND chip's manufacturer/chip ID from the boot log.
