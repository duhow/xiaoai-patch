#!/bin/sh

echo "[*] Applying patches"
for PATCHFILE in patches/*.patch patches/${MODEL}/*.patch; do
  echo ">> ${PATCHFILE}"
  patch -p1 --no-backup-if-mismatch -r /dev/null -d ${ROOTFS} < ${PATCHFILE}
done
