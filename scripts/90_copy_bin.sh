#!/bin/sh

echo "[*] Copying binary files"
for FILE in bin/*; do
  echo "    - $FILE > $ROOTFS/bin/"
  cp -f $FILE $ROOTFS/bin/
done
