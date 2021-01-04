#!/bin/sh

echo "[*] Adding symlink to ssh-keys in data"
ln -vsf /data/ssh $ROOTFS/root/.ssh
