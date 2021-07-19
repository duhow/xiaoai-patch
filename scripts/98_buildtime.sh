#!/bin/sh

echo "[*] Updating build time of image"
sed -i "/BUILDTS/s/'.*/'$(date +%s)'/" ${ROOTFS}/usr/share/mico/version
sed -i "/BUILDTIME/s/'.*/'$(date -R)'/" ${ROOTFS}/usr/share/mico/version
