#!/bin/sh

echo "[*] Copying binary files"
for FILE in bin/*; do
  cp -dvf $FILE $ROOTFS/bin/
done
