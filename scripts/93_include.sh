#!/bin/sh

FOLDER=include

echo "[*] Checking for include folder"
if [ ! -d "${FOLDER}/" ]; then
  echo "[*] Folder does not exist, skipping."
  exit
fi

echo "[*] Copying content to include"

rsync -avr ${FOLDER}/* $ROOTFS/

echo "[*] Running root chown"
chown -R root:root $ROOTFS
