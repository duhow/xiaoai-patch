services_dir = '/etc/init.d'
services_ignored = [
  'boot', 'coredump', 'done', 'led', 'silentboot', 'bluetoothd',
  'dlnainit', 'dnsmasq', 'gpio_switch', 'linein', 'logrotate',
  'mdplay', 'mediaplayer', 'messagingagent', 'mibrain_service',
  'mibt_mesh', 'mibt_mesh_proxy', 'mico_ai_crontab', 'mico_aivs_lab',
  'mico_helper', 'mico_ir_agent', 'miio', 'mitv-disc', 'nano_httpd',
  'odhcp6c', 'odhcpd', 'pns', 'pns_ubus_helper', 'quickplayer',
  'sound_effect', 'statpoints_daemon', 'sysctl', 'syslog-ng',
  'touchpad', 'umount', 'urandom_seed', 'voip', 'xiaomi_dns_server',
  'alsa', 'avahi-dnsconfd', 'cron', 'dbus'
]
services_allowed = [
  'adbd', 'alarm', 'avahi-daemon', 'bluetooth', 'wireless', 'dhcpc',
  'dropbear', 'listener', 'mpd', 'upmpdcli', 'shairport-sync',
  'snapclient', 'snapserver', 'triggerhappy',
]

config_listener = '/data/listener'
config_tts = '/data/tts.conf'

wakewords_porcupine = '/usr/share/porcupine/keywords'

lx06_infrared = '/sys/ir_tx_gpio/ir_data'
