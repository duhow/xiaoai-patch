#!/bin/sh

echo "[*] Deleting binary files"
for FILE in alarmd carrier_chinatelecom.sh carrier.sh mediaplayer messagingagent mdplay \
  bluez_mibt_ble mibt_ble bluez_mibt_classical mibt_mesh mibt_mesh_proxy mibt_mesh.automation mico_ble_service \
  miplayer mphelper mibrain_level mibrain_net_check mibrain_oauth_manager mibrain_service  \
  mipns-xiaomi mipns-sai mipns-horizon \
  mico_ai_crontab mico_vendor_helper mico_model_helper mico_aivs_lab mico-helper \
  heartbeatagent ciptool xiaomi_dns_server miio_helper \
  miio_client miio_client_helper miio_recv_line miio_send_line miio_service notifyd pns_ubus_helper pns_upload_helper \
  mitv_pstream nano_httpd quickplayer mico_voip_applite voip_applite voip_helper voip_service work_day_sync_service \
  mico_voip_alarm mico_voip_ubus_service mico_voip_service.sh upnp-disc ota-burnboot0 ota-burnuboot quark quarkd \
  statpoints statpoints_daemon matool miio_set_uid experience_plan cmcc_ims_service.sh pit_server \
  app_avk app_ble app_manager iozone mtd_crash_log didiagent config_mode linein check_mediaplayer_status \
  idmruntime mfgutil; do
  rm -vf $ROOTFS/usr/bin/$FILE
done
  rm -vf $ROOTFS/usr/bin/matool_*
  rm -vf $ROOTFS/usr/bin/procps-ng-*
  rm -vf $ROOTFS/bin/procps-ng-*

for FILE in collect_log.sh network_probe.sh; do
  rm -vf $ROOTFS/usr/sbin/$FILE
done

for FILE in imiflash; do
  rm -vf $ROOTFS/sbin/$FILE
done

# NOTE wakeup.sh is interesting :)
for FILE in EnterFactory boardupgrade.sh flash.sh lx01_get_crashlog bind_device.sh \
  ota notify.sh touchpad tplay wakeup.sh wuw_upload.sh; do
  rm -vf $ROOTFS/bin/$FILE
done

echo "[*] Deleting unused Xiaomi libs"
for FILE in libmibrain-common-sdk.so libmibrain-common-util.so libmibrainsdk.so \
	libxiaomi_crypto.so libxiaomi_didi.so libxiaomi_heartbeat.so libxiaomi_http.so libxiaomi_json.so \
	libxiaomimediaplayer.so libxiaomi_mico.so libxiaomi_miot.so libxiaomi_mosquitto.so libxiaomi_utils.so \
	libmdspeech.so libmdplay.so libffmpeg-miplayer.so libmimc_sdk.so libiotdcm.so libiotdcm_mdplay.so \
	libvoipengine.so libsai_miAPIs.so libmibrain-vendor-sdk.so libmibrain-util.so libota-burnboot.so \
	libDiracAPI_SHARED.so libdts.so libxaudio_engine.so libmesh.so libquark_lib.so libmivpm.so libvpm.so \
	libaivs_sdk.so libaivs-message-util.so libxiaomimediaplayerlite.so libmijia_ble_api.so \
	libsoup-2.4.so.1.8.0; do
  rm -vf $ROOTFS/usr/lib/$FILE
done

# fix repeated libs
for FILE in libnghttp2.so.14.13.2 libevtlog.so.0.0.0 libprocps.so.5.0.0; do
  if [ -f "${ROOTFS}/usr/lib/${FILE}" ]; then
    for CUTNAME in 3 2; do
      SUBNAME=$(echo $FILE | cut -d '.' -f 1-${CUTNAME})
      rm -vf ${ROOTFS}/usr/lib/${SUBNAME}
      ln -svf ${FILE} ${ROOTFS}/usr/lib/${SUBNAME}
    done
  fi
done

echo "[*] Deleting Xiaomi hotword detection model"
for NAME in xiaomi sai horizon mipns; do
  rm -rvf $ROOTFS/usr/share/$NAME
done
