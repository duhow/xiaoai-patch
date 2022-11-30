#!/bin/sh

echo "[*] Replacing factory default root password"
# in case that /data partition is not mounted, this will allow you to login.
# NOTE: Remember to set a custom password after flashing!

# password: root
# openssl passwd -5 -salt xiaoai root
HASH='$5$xiaoai$sry7iaqDMu/y7/yz5w1BcV26l2RGFBd6WHXiuLahL9D'

sed -i 's,^\(root:\)[^:]*\(:.*\)$,\1'"${HASH}"'\2,' $ROOTFS/etc/shadow

# show result
grep "root:" $ROOTFS/etc/shadow
