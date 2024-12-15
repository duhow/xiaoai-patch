#!/bin/sh

uci_get() { grep "option $1" ${FILE} | awk -F"'" '{print $2}'; }

echo "[*] Updating build version file"
FILE=${ROOTFS}/usr/share/mico/version
SYSTEM_FILE=${ROOTFS}/usr/share/mico/system.cfg
ROM_VERSION=$(uci_get "ROM")
GIT_COMMIT=$(git rev-parse HEAD 2>/dev/null)

# if already patched, use set ROOTFS value.
if [ `echo ${ROM_VERSION} | cut -d '.' -f1` -gt 1 ]; then
    ROM_VERSION=$(uci_get "ROOTFS")
fi

sed -i "/BUILDTS/s/'.*/'$(date +%s)'/" ${FILE}
sed -i "/BUILDTIME/s/'.*/'$(date -R)'/" ${FILE}
sed -i "/ROM/s/'.*/'$(date +%Y.%m.%d)'/" ${FILE}
sed -i "/ROOTFS/s/'.*/'${ROM_VERSION}'/" ${FILE}
if [ -n "$GIT_COMMIT" ]; then
  sed -i "/GTAG/s/'.*/'commit ${GIT_COMMIT}'/" ${FILE}
fi

sed -i '/buildts/s/".*"/"'"$(uci_get "BUILDTS")"'"/' ${SYSTEM_FILE}
sed -i '/buildtime/s/".*"/"'"$(uci_get "BUILDTIME")"'"/' ${SYSTEM_FILE}
sed -i '/version/s/".*"/"'"$(uci_get "ROM")"'"/' ${SYSTEM_FILE}
sed -i '/rootfs/s/".*"/"'"$(uci_get "ROOTFS")"'"/' ${SYSTEM_FILE}
sed -i '/gtag/s/".*"/"'"$(uci_get "GTAG" | cut -d ' ' -f2)"'"/' ${SYSTEM_FILE}