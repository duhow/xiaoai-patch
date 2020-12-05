#!/bin/sh

for SERVICE in \
  dbus work_day_sync_service xiaomi_dns_server mediaplayer messagingagent \
  wifitool mitv-disc miio pns mibrain_service mico_ai_crontab mico_ir_agent \
  nano_httpd pns_ubus_helper quickplayer voip mdplay mibt_mesh_proxy; do

  echo "[*] Deleting run service ${SERVICE}"
  rm -f $ROOTFS/etc/rc.d/S??${SERVICE}
done

echo "[*] Deleting unused config cmcc"
rm -f $ROOTFS/etc/config/cmcc

echo "[*] Removing cronjobs"
rm -rf $ROOTFS/etc/crontabs/*
