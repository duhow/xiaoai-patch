#!/bin/sh

uci_get() { grep "option $1" ${MICO_FILE} | awk -F"'" '{print $2}'; }
conf_check() { grep -q "${1}=" "$2" || echo "${1}=\"\"" >> "$2"; }

echo "[*] Updating build version file"
MICO_FILE=${ROOTFS}/usr/share/mico/version
SYSTEM_FILE=${ROOTFS}/usr/share/mico/system.cfg
ROM_VERSION=$(uci_get "ROM")
GIT_COMMIT=$(git rev-parse HEAD 2>/dev/null)

# if already patched, use set ROOTFS value.
if [ `echo ${ROM_VERSION} | cut -d '.' -f1` -gt 1 ]; then
    ROM_VERSION=$(uci_get "ROOTFS")
fi

sed -i "/BUILDTS/s/'.*/'$(date +%s)'/" ${MICO_FILE}
sed -i "/BUILDTIME/s/'.*/'$(date -R)'/" ${MICO_FILE}
sed -i "/ROM/s/'.*/'$(date +%Y.%m.%d)'/" ${MICO_FILE}
sed -i "/ROOTFS/s/'.*/'${ROM_VERSION}'/" ${MICO_FILE}
# TODO check how much does this change
sed -i "/LINUX/s/'.*/'${ROM_VERSION}'/" ${MICO_FILE}
sed -i "/CHANNEL/s/'.*/'custom'/" ${MICO_FILE}
if [ -n "$GITHUB_ACTIONS" ]; then
  sed -i "/CHANNEL/s/'.*/'release'/" ${MICO_FILE}
fi
if [ -n "$GIT_COMMIT" ]; then
  sed -i "/GTAG/s/'.*/'commit ${GIT_COMMIT}'/" ${MICO_FILE}
fi

sed -i '/buildts/s/".*"/"'"$(uci_get "BUILDTS")"'"/' ${SYSTEM_FILE}
sed -i '/buildtime/s/".*"/"'"$(uci_get "BUILDTIME")"'"/' ${SYSTEM_FILE}
sed -i '/version/s/".*"/"'"$(uci_get "ROM")"'"/' ${SYSTEM_FILE}
sed -i '/channel/s/".*"/"'"$(uci_get "CHANNEL")"'"/' ${SYSTEM_FILE}
sed -i '/rootfs/s/".*"/"'"$(uci_get "ROOTFS")"'"/' ${SYSTEM_FILE}
sed -i '/linux/s/".*"/"'"$(uci_get "LINUX")"'"/' ${SYSTEM_FILE}
sed -i '/gtag/s/".*"/"'"$(uci_get "GTAG" | cut -d ' ' -f2)"'"/' ${SYSTEM_FILE}

echo "[*] Updating os-release info"
rm -vf ${ROOTFS}/etc/openwrt_release ${ROOTFS}/etc/openwrt_version
OS_FILE=${ROOTFS}/etc/os-release

# NOTE: file may not exist, we need to create or replace
touch ${OS_FILE}
sed -i "/NAME=/s/=.*/=\"Xiaomi Speaker\"/" ${OS_FILE}
sed -i "/PRETTY_NAME=/s/=.*/=\"Xiaomi Speaker $(uci_get "HARDWARE") $(uci_get "ROM")\"/" ${OS_FILE}
sed -i "/VERSION=/s/=.*/=\"$(uci_get "ROM")\"/" ${OS_FILE}
sed -i "/VERSION_ID=/s/=.*/=\"$(uci_get "CHANNEL") ($(uci_get "ROM"))\"/" ${OS_FILE}
conf_check VERSION_CODENAME ${OS_FILE}
sed -i "/VERSION_CODENAME=/s/=.*/=\"librexiao\"/" ${OS_FILE}
sed -i "/BUILD_ID=/s/=.*/=\"$(uci_get "CHANNEL") ($(uci_get "ROM"))\"/" ${OS_FILE}
conf_check RELEASE_TYPE ${OS_FILE}
sed -i "/RELEASE_TYPE=/s/=.*/=\"$(uci_get "CHANNEL")\"/" ${OS_FILE}
sed -i "/HOME_URL=/s|=.*|=\"https://github.com/duhow/xiaoai-patch\"|" ${OS_FILE}
sed -i "/BUG_REPORT_URL=/s|=.*|=\"https://github.com/duhow/xiaoai-patch/issues/\"|" ${OS_FILE}

sed -i "/LEDE_DEVICE_MANUFACTURER=/s/=.*/=\"Xiaomi\"/" ${OS_FILE}
sed -i "/LEDE_DEVICE_MANUFACTURER_URL=/s|=.*|=\"https://www.mi.com/global/\"|" ${OS_FILE}
sed -i "/LEDE_DEVICE_PRODUCT=/s/=.*/=\"$(uci_get "HARDWARE")\"/" ${OS_FILE}
