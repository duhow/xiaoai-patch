#!/bin/sh

echo "[*] Checking for include folder"
if [ ! -d "include/" ]; then
  echo "[*] Folder does not exist, skipping."
  exit
fi

echo "[*] Listing all content to include"
find include/

cp -far include/* $ROOTFS/

echo "[*] Running root chown"
chown -R root:root $ROOTFS
