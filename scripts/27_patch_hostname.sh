#!/bin/sh

FILE=$ROOTFS/etc/rc.d/S51hostname
echo "[*] Updating hostname"

cat > $FILE <<EOF
#!/bin/sh /etc/rc.common

START=51

# update hostname

SN=\$(echo -n \`uci -c /data/etc get binfo.binfo.sn\` | tail -c -4)
MODEL=\$(uci -c /usr/share/mico get version.version.HARDWARE)
echo "\$MODEL-\$SN" > /proc/sys/kernel/hostname
EOF

chmod 755 $FILE
chown root:root $FILE
