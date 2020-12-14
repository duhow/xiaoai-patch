#!/bin/sh

echo "[*] Deleting binary files"
for FILE in alarmd bluez_mibt_ble bluez_mibt_classical carrier_chinatelecom.sh carrier.sh mediaplayer messagingagent mdplay \
  miplayer mibrain_level mibrain_net_check mibrain_oauth_manager mibrain_service mibt_mesh mibt_mesh_proxy mipns-xiaomi \
  miio_client miio_client_helper miio_recv_line miio_send_line miio_service notifyd pns_ubus_helper pns_upload_helper \
  mitv_pstream nano_httpd quickplayer voip_applite voip_helper voip_service work_day_sync_service; do
  echo "    - $FILE"
  rm -f $ROOTFS/usr/bin/$FILE
done

# NOTE wakeup.sh is interesting :)
for FILE in ota notify.sh touchpad tplay wakeup.sh wuw_upload.sh; do
  echo "    - $FILE"
  rm -f $ROOTFS/bin/$FILE
done
