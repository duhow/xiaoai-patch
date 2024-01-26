# Home Assistant Voice Satellite

Voice Assist Satellite for Home Assistant using Xiaomi LX06. Based on [rhasspy/wyoming-satellite](https://github.com/rhasspy/wyoming-satellite) and [duhow/xiaoai-patch](https://github.com/duhow/xiaoai-patch).

The [duhow/xiaoai-patch](https://github.com/duhow/xiaoai-patch) project supports more devices from Xiaomi/Xiaoai, but I'am focussing on the Xiaoai Speaker Pro alias LX06.

Difference to [duhow/xiaoai-patch](https://github.com/duhow/xiaoai-patch):
- full python 3.9
- active echo cancelling using [aec_cmdline](https://github.com/dr-ni/aec_cmdline) and [alsa-aec](https://github.com/SaneBow/alsa-aec)
- removed packages, because not needed anymore or size optimization (python takes a lot of space)
- some modifications for volume, LED or MPD for better integration into HA

## Useful commands

`docker build -t xiaoai-patch packages`

`docker run --rm -it -v $PWD:/xiaoai xiaoai-patch` (and `docker run --rm -it -v $PWD:/xiaoai xiaoai-patch ./packages.sh clean` for cleaning)

`sudo make clean all FILE=../mtd4_untouched.img MODEL=lx06`
