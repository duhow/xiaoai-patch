#!/bin/sh

BACK=$PWD
USR_SHARE=$ROOTFS/usr/share

if [ -d "$USR_SHARE/sound-vendor" ]; then
  echo "[*] Mixing all sound-vendors"

  SOUND_FOLDER=$USR_SHARE/sound-vendor
  cd $SOUND_FOLDER

  for FOLDER in *; do
    mkdir -p original
    mv -vf $FOLDER/* original/
    rm -rf $FOLDER
    ln -sf original $FOLDER
  done
elif [ -d "$USR_SHARE/sound" ]; then
  echo "[*] Moving sound content"

  SOUND_FOLDER=$USR_SHARE/sound
  cd $SOUND_FOLDER

  mkdir -p original
  mv -vf * original/
else
  echo "[!] Sound folder not detected! Skipping."
  exit
fi

echo "[*] Remove original chinese voices"
cd $BACK

for NAME in aux_on aux_off aux_stop_tip \
  bluetooth_already_connected bluetooth_connect bluetooth_disconnect bluetooth_failure \
  bluetooth_noPhone ims_callout_prefix internet_disconnect init_wifi_config init_wifi_success \
  mibrain_auth_failed mibrain_connect_timeout mibrain_network_unreachable mibrain_service_timeout \
  mibrain_service_unreachable mibrain_start_failed mic_off mic_on network_done_miio no_channel \
  reset_wait reset service_timeout setup_failure tts_vendor_demo unknown_action unknown_domain \
  unknown_service upgrade_later upgrade_now wakeup_ei_01 wakeup_ei_02 wakeup_mitv wakeup_wozai_01 \
  wakeup_zai_01 wakeup_zai_02 weak_network welcome wifi_disconnect; do
  rm -vf $SOUND_FOLDER/original/$NAME.*
done

cd $BACK

if [ -d "$USR_SHARE/sound-vendor" ]; then
  SOUND_FOLDER=sound-vendor

  echo "[*] Creating sound directory"
  cd $USR_SHARE
  rm -f sound
  mkdir -p sound
  cd $BACK
else
  SOUND_FOLDER=sound
fi

echo "[*] Linking factory sounds"
cd $USR_SHARE
for FILE in $SOUND_FOLDER/original/*; do
  NAME=$(basename $FILE)
  ln -sf /usr/share/$SOUND_FOLDER/original/$NAME sound/$NAME
done

cd $BACK

if [ -d "sound" ]; then
  echo "[*] Copying extra sounds"
  cp -av sound/* $USR_SHARE/sound
fi
