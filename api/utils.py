import socket
import fcntl
import struct
import subprocess
import re

def get_ip_address(ifname) -> str:
  s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
  return socket.inet_ntoa(fcntl.ioctl(
    s.fileno(),
    0x8915,  # SIOCGIFADDR
    struct.pack('256s', ifname[:15].encode('utf-8'))
  )[20:24])

def get_unify_key(key: str) -> str:
  try:
    with open(f'/sys/class/unifykeys/name', 'w') as f:
      f.write(key)
    with open(f'/sys/class/unifykeys/read', 'r') as f:
      return f.read().strip()
  except IOError as e:
    pass
  return ""

def get_device_id() -> str:
  did = get_unify_key('deviceid')
  if did:
    return did
  return ""

def get_wifi_mac_address() -> str:
  mac = get_unify_key('mac_wifi')
  if mac:
    return mac.upper()
  return ""

def get_bt_mac_address() -> str:
  mac = get_unify_key('mac_bt')
  if mac:
    return mac.upper()

  try:
    result = subprocess.run('hciconfig hci0'.split(' '), capture_output=True, text=True)
    if result.returncode == 0:
      match = re.search(r'BD Address: ([0-9A-F:]{17})', result.stdout)
      if match:
        return match.group(1)
  except Exception as e:
    pass
  return ""