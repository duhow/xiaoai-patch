#!/bin/sh

FILE=/bin/bash

if [ -f "${ROOTFS}/usr${FILE}" ] && [ ! -e "${ROOTFS}${FILE}" ]; then
  echo "[*] Adding symlink for bash"
  ln -svf /usr${FILE} ${ROOTFS}${FILE}
fi

if [ -f "${ROOTFS}${FILE}" ]; then
  echo "[*] Enabling ${FILE} as shell"
  echo "${FILE}" >> $ROOTFS/etc/shells
fi
