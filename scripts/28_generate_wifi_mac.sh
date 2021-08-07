#!/bin/sh

nv_43438a1=$ROOTFS/lib/firmware/nv_43438a1.txt
nv_43436p=$ROOTFS/lib/firmware/nv_43436p.txt
echo "[*] Updating wifi mac address"
new_mac=$(printf '00:90:4c:%02x:%02x:%02x\n' $[RANDOM%256] $[RANDOM%256] $[RANDOM%256])

sed -i "s/macaddr=.*/macaddr=${new_mac}/" ${nv_43438a1}
sed -i "s/macaddr=.*/macaddr=${new_mac}/" ${nv_43436p}

sed -i "s/il0macaddr=.*/il0macaddr=${new_mac}/" ${nv_43438a1}
sed -i "s/il0macaddr=.*/il0macaddr=${new_mac}/" ${nv_43436p}

chmod 755 $nv_43438a1 $nv_43436p
chown root:root $nv_43438a1 $nv_43436p
