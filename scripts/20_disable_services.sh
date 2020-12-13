#!/bin/sh

for SERVICE in \
  dbus work_day_sync_service xiaomi_dns_server mediaplayer messagingagent \
  wifitool mitv-disc miio pns mibrain_service mico_ai_crontab mico_ir_agent \
  nano_httpd pns_ubus_helper quickplayer voip mdplay mibt_mesh_proxy \
  statpoints_daemon alarm notify dlnainit touchpad sound_effect; do

  echo "[*] Deleting run service ${SERVICE}"
  rm -f $ROOTFS/etc/rc.d/S??${SERVICE}
done

echo "[*] Deleting unused config cmcc"
rm -f $ROOTFS/etc/config/cmcc

echo "[*] Removing cronjobs"
shasum $ROOTFS/etc/crontabs/*
rm -rf $ROOTFS/etc/crontabs/*

FILE=$ROOTFS/etc/init.d/pns
SHA=$(shasum $FILE | awk '{print $1}')
if [ "$SHA" = "608cfccef04f854b9ea958c583c85fa71659948d" ]; then
echo "[*] Patching Mi PNS service"
sed -i '199 a     [ -x /data/enable_pns ] || return 0' $FILE
fi
