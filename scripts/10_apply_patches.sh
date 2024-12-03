#!/bin/sh

if ! command -v patch >/dev/null ; then
  echo "[!] patch command not found, failing hard!"
  exit 1
fi

echo "[*] Applying patches"
for PATCHFILE in patches/*.patch patches/${MODEL}/*.patch; do
  echo ">> ${PATCHFILE}"
  patch -p1 --no-backup-if-mismatch -r /dev/null -d ${ROOTFS} < ${PATCHFILE}
done

true
