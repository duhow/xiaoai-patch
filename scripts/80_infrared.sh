#!/bin/sh

if [ "${MODEL}" != "lx06" ]; then
  echo "[-] Model not compatible, skipping."
  exit
fi

DEF_PORT=8766

echo "[*] Creating folder structure" 

FOLDER=${ROOTFS}/usr/share/irplus

mkdir -p ${FOLDER}

echo "[*] Adding code"

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
    mkdir -p \$WEBROOT
    cp -rf /usr/share/irplus/* \${WEBROOT}/cgi-bin

    procd_open_instance
    procd_set_param command \$PROG -f -h \${WEBROOT} -p \${PORT}
    procd_set_param respawn

    procd_add_mdns "irplus" "tcp" "\$PORT" "path=/cgi-bin/ir.cgi"

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
   <txt-record>path=/cgi-bin/ir.cgi</txt-record>
  </service>
</service-group>
EOF
