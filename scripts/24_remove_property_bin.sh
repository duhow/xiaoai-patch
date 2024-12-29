#!/bin/sh

echo "[*] Deleting binary files"
for FILE in alarmd carrier_chinatelecom.sh carrier.sh mediaplayer messagingagent mdplay mdplay_helper \
  bluez_mibt_ble mibt_ble bluez_mibt_classical \
  mibt_mesh mibt_mesh_rtl mibt_mesh_proxy mibt_mesh.automation mico_ble_service \
  miplayer mphelper mibrain_level mibrain_net_check mibrain_oauth_manager mibrain_service  \
  mipns-xiaomi mipns-sai mipns-horizon \
  mico_ai_crontab mico_vendor_helper mico_model_helper mico_aivs_lab mico-helper \
  heartbeatagent xiaomi_dns_server miio_helper miio_mpkg idmruntime \
  mijia_automation \
  miio_client miio_client_helper miio_recv_line miio_send_line miio_service notifyd pns_ubus_helper pns_upload_helper \
  mitv_pstream nano_httpd quickplayer mico_voip_applite voip_applite voip_helper voip_service work_day_sync_service \
  mico_voip_alarm mico_voip_ubus_service mico_voip_service.sh mico_voip_service mico_voip_service_helper mico_voip_ubus_helper \
  minet_client minet_service.sh telecom_plugind telecom_zhejiangd \
  upnp-disc ota-burnboot0 ota-burnuboot quark quarkd \
  statpoints statpoints_daemon matool miio_set_uid experience_plan \
  cmcc-ims cmcc_ims_service.sh cmcc-dm-deamon cmcc-andlink-deamon cmcc_helper cmcc_andlink_daemon \
  hci_tool pit_server \
  app_avk app_ble app_manager iozone mtd_crash_log didiagent config_mode linein check_mediaplayer_status \
  idmruntime mfgutil; do
  rm -vf $ROOTFS/usr/bin/$FILE
done
  # matool = Messaging Agent, core of speaker.
  # we don't use this service, neither we interact with API services.
  rm -vf $ROOTFS/usr/bin/matool_*
  rm -vf $ROOTFS/usr/bin/procps-ng-*
  rm -vf $ROOTFS/bin/procps-ng-*

for FILE in traceroute ssh_enable sound_effect qplayer usign urlcheck.sh upload_kernel_crash.sh dbus-launch.real \
  cpu_monitor fileop pwdx vmstat volctl tload snice skill ; do
  rm -vf $ROOTFS/usr/bin/$FILE
done

for FILE in collect_log.sh network_probe.sh tcpdump \
  pam_tally pam_tally2 pam_timestamp_check unix_chkpwd unix_update ; do
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
	libvad.so libvoip.so libvoipengine.so libsai_miAPIs.so libmibrain-vendor-sdk.so libmibrain-util.so libota-burnboot.so \
	libDiracAPI_SHARED.so libdts.so libxaudio_engine.so libmesh.so libquark_lib.so libmivpm.so libvpm.so \
	libaivs_sdk.so libaivs-message-util.so libxiaomimediaplayerlite.so libmijia_ble_api.so \
	libmilink.so libagora-rtc-sdk.so libsoup-2.4.so.1.8.0; do
  rm -vf $ROOTFS/usr/lib/$FILE
done

# not used in LX06 after removing bloatware
for FILE in libldns.so.1.6.17 liblua.so.5.1.5 libthrift_c_glib.so.0.0.0 libxmdtransceiver.so \
  libstack.so liblibma.so \
  libgmp.so.10.3.2 libgmp.so.10.3.0 libgnutls.so.30.14.8 libgnutls.so.30.6.3 libhogweed.so.4.3 libhogweed.so.4.1 \
  libgupnp-1.0.so.4.0.1 libgssdp-1.0.so.3.0.1 \
  libevent-2.0.so.5.1.10 libevent_{core,extra,openssl,pthreads}-2.0.so.5.1.10 \
  libprotobuf-c.so.1.0.0 libprotobuf.so libglog.so.0 \
  lib{ncurses,form,menu,panel}{,w}.so.{6.0,5.9} \
  libnettle.so.6.3 libnettle.so.6.1 libprocps.so.5.0.0 libprocps.so.5 libprocps.so \
  libgflags.so.2.2.2 libgflags_nothreads.so.2.2.2 libdplus.so libcares.so.2.2.0 \
  libattr.so.1.1.2448 libuclient.so libutils.so libwrap.so.0.7.6 ; do
  rm -vf $ROOTFS/usr/lib/$FILE
done

# IMPORTANT! L09A micocfg uses libmbedtls.so.9 -> libmbedtls.so.1.3.14 , otherwise wifi is locked!
# IMPORTANT! LX01 (new) micocfg uses libmbedtls.so.10 -> libmbedtls.so.2.6.0. CANNOT SWAP WITH libssl!
# IMPORTANT! LX01 (new) micocfg uses libcrypto.1.0.0
# libmbedcrypto.so.2.6.0 libmbedtls.so.2.6.0 libmbedtls.so.1.3.{14,16} libmbedx509.so.2.6.0 

# removed from L09A
for FILE in libnetfilter_conntrack.so.3.6.0 libnfnetlink.so.0.2.0 libpcap.so.1 libpcap.so.1.3.0 \
  libprotobuf-lite.so.13.0.0 libwebsockets.so ; do
  rm -vf $ROOTFS/usr/lib/$FILE
done

rm -vf $ROOTFS/usr/lib/.*_installed
rm -rvf $ROOTFS/usr/share/dlna
rm -rvf $ROOTFS/usr/share/bash-completion
rm -vf $ROOTFS/etc/diracmobile.config.* # S12?
rm -vf $ROOTFS/usr/lib/alsa-lib/libasound_module*.la # only libtool library file, unused
rm -rvf $ROOTFS/usr/lib/opkg

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
