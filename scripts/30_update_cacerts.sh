#!/bin/sh

URL=https://curl.haxx.se/ca/cacert.pem

echo "[*] Downloading CA list from: $URL"
FILE=$ROOTFS/etc/ssl/certs/ca-cert.crt

rm $FILE
curl -s -o "$FILE" -L "$URL"

chown root.root $FILE
chmod 644 $FILE
shasum $FILE

URL=https://deb.debian.org/debian/pool/main/c/ca-certificates/ca-certificates_20210119_all.deb

echo "[*] Downloading ca-certificates: $URL"
TARGET=$(mktemp -d)
BACK=$PWD

cd $TARGET
curl -s -o $TARGET/ca.deb -L "$URL"
ar x $TARGET/ca.deb
tar xf $TARGET/data.tar.xz -C $TARGET
cd $BACK

echo "[*] Copying certificates"
cp -vf $TARGET/usr/share/ca-certificates/mozilla/* $ROOTFS/etc/ssl/certs/

rm -rf $TARGET
