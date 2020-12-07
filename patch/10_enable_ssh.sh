#!/bin/sh

# Remove disabling SSH service
FILE=$ROOTFS/etc/init.d/dropbear
echo "[*] Removing service lock"
sed -i "s/return 0/#return 0/" $FILE
sed -i "s/ssh_en=.*/ssh_en=1/" $FILE
shasum $FILE

# Enable root SSH
FILE=$ROOTFS/etc/config/dropbear
echo "[*] Enabling PasswordAuth and RootPasswordAuth"
sed -i -e "/PasswordAuth/s/'0'/'1'/g" $FILE
shasum $FILE
