#!/bin/sh

echo "[*] Applying patches"
for PATCHFILE in patches/*; do
  patch -p1 -d ${ROOTFS} < ${PATCHFILE}
done
