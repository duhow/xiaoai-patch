#!/bin/sh

FILE=/bin/bash

if [ -f "${ROOTFS}${FILE}" ]; then
  echo "[*] Enabling ${FILE} as shell"
  echo "${FILE}" >> $ROOTFS/etc/shells
fi
