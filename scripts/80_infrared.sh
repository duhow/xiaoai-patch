#!/bin/sh

if [ "${MODEL}" != "lx06" ]; then
  echo "[-] Model not compatible, skipping."
  exit
fi

DEF_PORT=8766
DEF_EXEC=cgi-bin/ir.cgi

echo "[*] Creating folder structure" 

FOLDER=${ROOTFS}/usr/share/irplus

mkdir -p ${FOLDER}

echo "[*] Adding code"

cat > ${FOLDER}/index.html << EOF
<html>
<head>
<style>
code { border: 2px solid black; display: inline-block; padding: 5px; clear: both; }
</style>
</head>
<body>
<h1>irplus remote service</h1>
<p>Configure your Android app to connect remotely via Wifi to endpoint:</p>
<code>http://SPEAKER_IP:${DEF_PORT}/${DEF_EXEC}</code>
<p><a href="https://play.google.com/store/apps/details?id=net.binarymode.android.irpluslan">Download Android app</a></p>
</body>
</html>
EOF

cat > ${FOLDER}/ir.cgi << EOF
#!/bin/sh

# irplus - Infrared remote
# https://irplus-remote.github.io/#wifi

if ! echo \${QUERY_STRING} | grep -q "code="; then
  echo "Status: 400 Bad Request"
  exit 1
fi

CODE=\$(echo \${QUERY_STRING} | tr '&' '\n' | grep "code=" | tail -n1 | cut -d '=' -f 2 | tr '+' ',')

if [ -z "\${CODE}" ]; then
  echo "Status: 400 Bad Request"
  exit 2
fi

if ! echo \${CODE} | grep -q -E '^[0-9,]+$'; then
  echo "Status: 400 Bad Request"
  exit 3
fi

echo \${CODE} > /sys/ir_tx_gpio/ir_data && echo "Status: 200 OK"
EOF

chmod 755 ${FOLDER}/ir.cgi

# -----

SERVICE=$ROOTFS/etc/rc.d/S91irplus
echo "[*] Adding service"

cat > $SERVICE <<EOF
#!/bin/sh /etc/rc.common

START=91
USE_PROCD=1

WEBROOT=/tmp/irplus
PROG=/bin/httpd
PORT=$DEF_PORT

start_service() {
    MODEL=\$(uci -c /usr/share/mico get version.version.HARDWARE)
    [ "\$MODEL" != "LX06" ] && return
    mkdir -p \$WEBROOT
    ln -sf . \$WEBROOT/cgi-bin
    cp -rf /usr/share/irplus/* \${WEBROOT}

    procd_open_instance
    procd_set_param command \$PROG -f -h \${WEBROOT} -p \${PORT}
    procd_set_param respawn

    procd_add_mdns "irplus" "tcp" "\$PORT" "path=/$DEF_EXEC"

    procd_close_instance
}

EOF

chmod 755 $SERVICE

# -----

echo "[*] Adding avahi discover service"
FILE=${ROOTFS}/etc/avahi/services/irplus.service
mkdir -p $(dirname ${FILE})

cat > ${FILE} << EOF
<?xml version="1.0" standalone='no'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
 <name replace-wildcards="yes">%h</name>
  <service>
   <type>_irplus._tcp</type>
   <port>$DEF_PORT</port>
   <txt-record>path=/$DEF_EXEC</txt-record>
  </service>
</service-group>
EOF
