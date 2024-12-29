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

cd $BACK
if [ -d "$USR_SHARE/common_sound" ]; then
  echo "[*] Moving common sound"
  FOLDER="$USR_SHARE/common_sound"

  mv -vf $FOLDER/* $SOUND_FOLDER/original/
  rm -rf $FOLDER
  ln -sf `basename $SOUND_FOLDER`/original $FOLDER
fi

echo "[*] Remove original chinese voices"
cd $BACK

for NAME in aux_on aux_on_stereo aux_off aux_stop_tip \
  bluetooth_already_connected bluetooth_connect bluetooth_disconnect bluetooth_failure \
  bluetooth_noPhone bluetooth_discoverable ims_callout_prefix internet_disconnect init_wifi_config init_wifi_success \
  mibrain_auth_failed mibrain_auth_failed_loading mibrain_connect_timeout mibrain_network_unreachable \
  mibrain_service_timeout mibrain_service_unreachable mibrain_start_failed mibrain_service_unavailable \
  voip_ringback voip_ringing voip_alarm mic_off mic_on no_channel \
  reset_wait reset service_timeout setup_failure tts_vendor_demo unknown_action unknown_domai unknown_domain \
  unknown_service upgrade_later upgrade_now wakeup_ei_01 wakeup_ei_02 wakeup_mitv wakeup_wozai_01 \
  wakeup_zai_01 wakeup_zai_02 weak_network welcome wifi_disconnect wifi_timeout_exit_config \
  alarmDefault first_voice \
  network_done_init network_done_miio reminder_default timer_default alarmDefault7s; do
  rm -vf $SOUND_FOLDER/original/$NAME.*
done

if [ "$MODEL" = "lx01" ] ; then
  for NAME in voip_ringing.mp3 voip_ringback.mp3 bluetooth_noSpeaker.wav timer_default.opus notice.wav \
    enter_config_mode.wav wakeup2.wav voip_on.wav voip_off.wav network_done.wav minet_found.mp3 \
    brainTurnDownVol.wav brainTurnUpVol.wav \
    wakeup_ei.wav wakeup_wozai.wav wakeup_zai.wav ; do
  rm -vf $SOUND_FOLDER/original/$NAME
  done
fi

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
