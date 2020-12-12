#!/bin/sh

# Remove disabling SSH service
FILE=$ROOTFS/etc/init.d/dropbear

SHA=$(shasum $FILE | awk '{print $1}')
if [ "$SHA" = "72c7b9c1e85abf3b0a8bbe1d108f387bc0400473" ]; then
echo "[*] Removing service lock with static patch"
sed -i -e '121,125d' $FILE
fi

echo "[*] Removing service lock"
sed -i "s/return 0/#return 0/" $FILE
sed -i "s/ssh_en=.*/ssh_en=1/" $FILE
shasum $FILE

# Enable root SSH
FILE=$ROOTFS/etc/config/dropbear
echo "[*] Enabling PasswordAuth and RootPasswordAuth"
sed -i -e "/PasswordAuth/s/'0'/'1'/g" $FILE
shasum $FILE
