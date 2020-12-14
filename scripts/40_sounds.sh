#!/bin/sh

echo "[*] Mixing all sounds"

BACK=$PWD
USR_SHARE=$ROOTFS/usr/share
cd $USR_SHARE/sound-vendor

for FOLDER in *; do
  mkdir -p original
  mv -f $FOLDER/* original/
  rm -rf $FOLDER
  ln -s original $FOLDER
done

echo "[*] Remove original chinese voices"
cd $BACK
SOUND_FOLDER=$ROOTFS/usr/share/sound-vendor

for NAME in aux_on aux_off aux_stop_tip \
  bluetooth_already_connected bluetooth_connect bluetooth_disconnect bluetooth_failure \
  bluetooth_noPhone ims_callout_prefix internet_disconnect init_wifi_config init_wifi_success \
  mibrain_auth_failed mibrain_connect_timeout mibrain_network_unreachable mibrain_service_timeout \
  mibrain_service_unreachable mibrain_start_failed mic_off mic_on network_done_miio no_channel \
  reset_wait reset service_timeout setup_failure tts_vendor_demo unknown_action unknown_domain \
  unknown_service upgrade_later upgrade_now wakeup_ei_01 wakeup_ei_02 wakeup_mitv wakeup_wozai_01 \
  wakeup_zai_01 wakeup_zai_02 weak_network welcome wifi_disconnect; do
  echo "    - $NAME"
  rm -f $USR_SHARE/sound-vendor/original/$NAME.*
done

echo "[*] Creating sound directory and linking factory sounds"
cd $BACK
cd $USR_SHARE
rm -f sound
mkdir -p sound
for FILE in sound-vendor/original/*; do
  NAME=$(basename $FILE)
  ln -s /usr/share/sound-vendor/original/$NAME sound/$NAME
done

cd $BACK

if [ -d "sound" ]; then
  echo "[*] Copying extra sounds"
  cp -ar sound/* $USR_SHARE/sound
fi
