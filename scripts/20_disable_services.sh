#!/bin/sh

echo "[*] Deleting run services"
for SERVICE in \
  work_day_sync_service xiaomi_dns_server mediaplayer messagingagent \
  wifitool mitv-disc miio pns mibrain_service mico_ai_crontab mico_ir_agent \
  nano_httpd pns_ubus_helper quickplayer voip mdplay mibt_mesh_proxy \
  didiagent mico_voip_ubus_service aw_upgrade_autorun \
  mico_helper miot_agent mico_aivs_lab \
  statpoints_daemon alarm notify dlnainit touchpad sound_effect linein; do

  rm -vf $ROOTFS/etc/rc.d/S??${SERVICE}
done

echo "[*] Deleting unused config cmcc"
rm -vf $ROOTFS/etc/config/cmcc

echo "[*] Removing cronjobs"
shasum $ROOTFS/etc/crontabs/*
rm -vf $ROOTFS/etc/crontabs/*
