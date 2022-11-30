#!/bin/sh

echo "[*] Adding symlink to ssh-keys in data"
ln -vsf /data/ssh $ROOTFS/root/.ssh
#ln -vsf /data/ssh $ROOTFS/etc/dropbear
