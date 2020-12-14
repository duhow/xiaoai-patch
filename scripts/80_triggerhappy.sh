#!/bin/sh

echo "[*] Creating startup program for Triggerhappy"

FILE=$ROOTFS/etc/init.d/thd
cat > $FILE <<EOF
#!/bin/sh /etc/rc.common

START=70
USE_PROCD=1

start_service() {
  procd_open_instance
  procd_set_param command /bin/thd --triggers /etc/thd.conf --socket /var/run/thd.sock /dev/input/event0
  procd_set_param respawn 3600 5 0
  procd_close_instance
}

stop_service() {
    pkill -x thd
}
EOF

chmod 755 $FILE
chown root:root $FILE

BACK=$PWD
cd $ROOTFS/etc/rc.d
ln -s ../init.d/thd S70triggerhappy
cd $BACK

echo "[*] Creating default rules for Triggerhappy"

cat > $ROOTFS/etc/thd.conf <<EOF
KEY_VOLUMEUP    1  /bin/volume down
KEY_MENU        1  /bin/volume up
EOF

