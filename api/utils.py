import socket
import fcntl
import struct
import subprocess
import os
import re
from typing import Union
import const
from config import ConfigUci

def get_ip_address(ifname) -> str:
  s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
  return socket.inet_ntoa(fcntl.ioctl(
    s.fileno(),
    0x8915,  # SIOCGIFADDR
    struct.pack('256s', ifname[:15].encode('utf-8'))
  )[20:24])

def get_uptime() -> int:
  with open('/proc/uptime', 'r') as f:
    return int(float(f.readline().split()[0]))

def get_load_avg(full: bool = False) -> Union[float, list[float]]:
  with open('/proc/loadavg', 'r') as f:
    if not full:
      return float(f.readline().split()[0])
    return [float(x) for x in f.readline().split()[:3]]

def get_model() -> str:
  system_version = ConfigUci(const.mico_version)
  return system_version.HARDWARE

def get_memory_usage() -> int:
  with open('/proc/meminfo', 'r') as f:
    total = 0
    available = 0
    free = 0
    for line in f:
      if line.startswith('MemTotal:'):
        total = int(line.split()[1])
      elif line.startswith('MemAvailable:'):
        available = int(line.split()[1])
      elif line.startswith('MemFree:'):
        free = int(line.split()[1])
      if total and available:
        break
    if not available and free:
      return (total - free)
    return (total - available)

def get_volume(mixer: str = "mysoftvol") -> Union[int, None]:
  """ Returns volume 0-100%, ALSA value is 0-255 """
  mixers = const.volume_controls.keys()
  if mixer not in mixers:
    raise ValueError(f"Invalid mixer name: {mixer}")

  try:
    result = subprocess.run(['amixer', 'get', mixer], capture_output=True, text=True)
    if result.returncode == 0:
      match = re.search(r'\[([0-9]+)%\]', result.stdout)
      if match:
        return int(match.group(1))
  except Exception as e:
    pass
  return None

def set_volume(mixer: str = "mysoftvol", volume: int = 0) -> bool:
  """ Sets volume 0-100 """
  volume = max(0, min(100, volume))
  volume = int(volume * 255 / 100)

  mixers = const.volume_controls.keys()
  if mixer not in mixers:
    raise ValueError(f"Invalid mixer name: {mixer}")

  try:
    result = subprocess.run(['amixer', 'set', mixer, f'{volume}'], capture_output=True, check=True)
    return result.returncode == 0
  except Exception as e:
    pass
  return False

def get_unify_key(key: str) -> str:
  try:
    with open(f'/sys/class/unifykeys/name', 'w') as f:
      f.write(key)
    with open(f'/sys/class/unifykeys/read', 'r') as f:
      return f.read().strip()
  except IOError as e:
    pass
  return ""

def get_private_lx01(key: str) -> str:
  private = '/dev/by-name/private'
  if not os.path.exists(private):
    return False
  try:
    with open(private, 'rb') as f:
      data = f.read(512).decode('utf-8', errors='ignore').strip()
      key_values = {}
      for line in data.split('\n'):
        if '=' in line:
          k, v = line.split('=', 1)
          key_values[k.strip()] = v.strip()
      return key_values.get(key, "")
  except IOError as e:
    pass
  return ""

def get_device_id() -> str:
  for run in (lambda: get_unify_key('deviceid'), lambda: get_private_lx01('sn')):
    did = run()
    if did:
      return did
  return ""

def get_wifi_mac_address() -> str:
  for run in (lambda: get_unify_key('mac_wifi'), lambda: get_private_lx01('mac')):
    mac = run()
    if mac:
      return mac.upper()
  return ""

def get_bt_mac_address() -> str:
  for run in (lambda: get_unify_key('mac_bt'), lambda: get_private_lx01('bt')):
    mac = run()
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