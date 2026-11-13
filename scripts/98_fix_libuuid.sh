#!/bin/sh
echo "[*] Updating libuuid in rootfs"
cp -avf build-packages/staging/armv7/lib/libuuid.so* "$ROOTFS/lib/"
cp -avf build-packages/staging/armv7/lib/libuuid.so* "$ROOTFS/usr/lib/"
