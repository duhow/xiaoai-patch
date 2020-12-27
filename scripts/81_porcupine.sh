#!/bin/sh

echo "[*] Creating startup program for Porcupine (hotword detector)"

FILE=$ROOTFS/etc/init.d/listener
cat > $FILE <<EOF
#!/bin/sh /etc/rc.common

START=98
USE_PROCD=1

EXTRA_COMMANDS="status"

start_service() {
  ps | grep -v grep | grep porcupine_launcher -q
  if [ \$? -eq 0 ]; then
    stop_service
    return
  fi

  # unmute led
  /bin/shut_led 7 &
  [ -f /usr/share/sound/unmute.wav ] && aplay -Dnotify /usr/share/sound/unmute.wav &>/dev/null &

  procd_open_instance
  procd_set_param command /usr/bin/porcupine_launcher
  procd_set_param respawn 3600 5 0
  procd_close_instance
}

stop_service() {
  # mute led
  /bin/show_led 7 &

  pkill -x porcupine_launcher
  pkill -x porcupine
  [ -f /usr/share/sound/mute.wav ] && aplay -Dnotify /usr/share/sound/mute.wav &>/dev/null &
}

status() {
  _check
  if [ \$? -eq 0 ]; then
    echo "listener is running."
    return 0
  else
    echo "listener is stopped."
    return 1
  fi
}
EOF

chmod 755 $FILE
chown root:root $FILE

BACK=$PWD
cd $ROOTFS/etc/rc.d
ln -s ../init.d/listener S98listener
cd $BACK

echo "[*] Adding rules for Triggerhappy mute"

cat >> $ROOTFS/etc/thd.conf <<EOF
KEY_HOME        1  pgrep porcupine &>/dev/null && /etc/init.d/listener stop || /etc/init.d/listener start
EOF

