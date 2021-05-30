#!/bin/sh

echo "[*] Applying patches"
for PATCHFILE in patches/*; do
  patch -p1 --no-backup-if-mismatch -r /dev/null -d ${ROOTFS} < ${PATCHFILE}
done
