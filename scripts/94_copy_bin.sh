#!/bin/sh

echo "[*] Copying binary files"
for FILE in bin/*; do
  cp -vf $FILE $ROOTFS/bin/
done
