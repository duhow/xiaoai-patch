#!/bin/sh

echo "[*] Deleting binary files"
for FILE in alarmd bluez_mibt_ble bluez_mibt_classical carrier_chinatelecom.sh carrier.sh mediaplayer messagingagent mdplay \
  miplayer mibrain_level mibrain_net_check mibrain_oauth_manager mibrain_service mibt_mesh mibt_mesh_proxy mipns-xiaomi \
  miio_client miio_client_helper miio_recv_line miio_send_line miio_service notifyd pns_ubus_helper pns_upload_helper \
  mitv_pstream nano_httpd quickplayer voip_applite voip_helper voip_service work_day_sync_service mtd_crash_log; do
  echo "    - $FILE"
  rm -f $ROOTFS/usr/bin/$FILE
done

# NOTE wakeup.sh is interesting :)
for FILE in ota notify.sh touchpad tplay wakeup.sh wuw_upload.sh; do
  echo "    - $FILE"
  rm -f $ROOTFS/bin/$FILE
done

echo "[*] Deleting unused Xiaomi libs"
for FILE in libmibrain-common-sdk.so libmibrain-common-util.so libmibrainsdk.so \
	libxiaomi_crypto.so libxiaomi_didi.so libxiaomi_heartbeat.so libxiaomi_http.so libxiaomi_json.so \
	libxiaomimediaplayer.so libxiaomi_mico.so libxiaomi_miot.so libxiaomi_mosquitto.so libxiaomi_utils.so \
	libmdspeech.so libmdplay.so libffmpeg-miplayer.so libmimc_sdk.so libiotdcm.so libiotdcm_mdplay.so \
	libDiracAPI_SHARED.so libdts.so libxaudio_engine.so libmesh.so \
	libprocps.so.5 libprocps.so libevtlog.so.0 libevtlog.so; do
  echo "    - $FILE"
  rm -f $ROOTFS/usr/lib/$FILE
done

# fix repeated libs
ln -s libevtlog.so.0.0.0 $ROOTFS/usr/lib/libevtlog.so
ln -s libevtlog.so.0.0.0 $ROOTFS/usr/lib/libevtlog.so.0

ln -s libprocps.so.5.0.0 $ROOTFS/usr/lib/libprocps.so
ln -s libprocps.so.5.0.0 $ROOTFS/usr/lib/libprocps.so.5

echo "[*] Deleting Xiaomi hotword detection model"
rm -rvf $ROOTFS/usr/share/xiaomi
