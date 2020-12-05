#!/bin/sh

# Remove disabling SSH service
echo "[*] Removing service lock"
sed -i "s/return 0/#return 0/" $ROOTFS/etc/init.d/dropbear
sed -i "s/ssh_en=.*/ssh_en=1/" $ROOTFS/etc/init.d/dropbear

# Enable root SSH
echo "[*] Enabling PasswordAuth and RootPasswordAuth"
sed -i -e "/PasswordAuth/s/'0'/'1'/g" $ROOTFS/etc/config/dropbear

