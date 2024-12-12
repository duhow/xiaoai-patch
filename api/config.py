import os
import re

class ConfigManager:
  def __init__(self, file_path: str):
    self.file_path = file_path
    if not os.path.exists(self.file_path):
      with open(self.file_path, 'w') as f:
        pass

  def __getattr__(self, key):
    return self.get(key)

  def __setattr__(self, key, value):
    if key in ['file_path']:
      super().__setattr__(key, value)
    else:
      self.set(key, value)

  def __iter__(self):
    return iter(self.to_dict().items())

  def _process_value(self, value):
    """ Transform value from string to type """
    if value.startswith('"') and value.endswith('"'):
      value = value[1:-1]
    if value.lower() == 'true':
      return True
    if value.lower() == 'false':
      return False
    if value.isdigit():
      return int(value)
    return value

  def to_dict(self):
    result = {}
    with open(self.file_path, 'r') as f:
      for line in f:
        if line.startswith('#'):
          continue
        if '=' in line:
          key, value = line.strip().split('=', 1)
          if 'token' in key.lower():
            continue
          value = self._process_value(value)
          result[key] = value
    return result

  def get(self, key):
    with open(self.file_path, 'r') as f:
      for line in f:
        if line.startswith('#'):
          continue
        if line.startswith(key + '='):
          value = line[len(key) + 1:].strip()
          value = self._process_value(value)
          return value
    return None

  def set(self, key, value):
    lines = []
    found = False
    if isinstance(value, bool):
      value = str(value).lower()
    if ' ' in value:
      value = f'"{value}"'
    new_value = f'{key}={value}\n'
    with open(self.file_path, 'r') as f:
      for line in f:
        if line.startswith(key + '=') and not line.startswith('#'):
          if line == new_value:
            return True
          # update value instead of adding current line
          lines.append(new_value)
          found = True
        else:
          lines.append(line)
    if not found:
      lines.append(new_value)
    with open(self.file_path, 'w') as f:
      f.writelines(lines)

class ConfigUci:
  def __init__(self, file_path: str):
    self.file_path = file_path
    if not os.path.exists(self.file_path):
      raise FileNotFoundError(f"File not found: {self.file_path}")
    self.main_section = None
    self.data = dict()
    self.read()

  def __getattr__(self, key):
    if self.main_section:
      return self.data[self.main_section].get(key.lower())
    return self.data.get(key)

  def _process_value(self, value):
    """ Transform value from string to type """
    if value.startswith('"') and value.endswith('"'):
      value = value[1:-1]
    if value.lower() == 'true':
      return True
    if value.lower() == 'false':
      return False
    if value.isdigit():
      return int(value)
    return value

  def read(self):
    result = {}
    current_section = None

    with open(self.file_path, 'r') as f:
      for line in f:
        line = line.strip()
        if line.startswith('#') or not line:
          continue
        if line.startswith('config'):
          current_section = line.split()[1].strip("'")
          if self.main_section is None:
            self.main_section = current_section
          result[current_section] = {}
        elif line.startswith('option') and current_section:
          match = re.match(r"option\s+'?(\w+)'?\s+'(.+)'", line)
          if not match:
            continue
          key, value = match.groups()
          key = key.lower()
          value = self._process_value(value.strip("'"))
          result[current_section][key] = value

    self.data = result

  def to_dict(self) -> dict:
    if self.main_section:
      return self.data[self.main_section]
    return self.data

  def get(self, key: str, section: str = ""):
    if self.main_section and not section:
      section = self.main_section
    return self.data[section].get(key)

#  def set(self, section, key, value):
#    config_dict = self.to_dict()
#    if section not in config_dict:
#      config_dict[section] = {}
#    config_dict[section][key] = value
#    self._write_config(config_dict)
#
#  def _write_config(self, config_dict):
#    lines = []
#    for section, options in config_dict.items():
#      lines.append(f"config '{section}'\n")
#      for key, value in options.items():
#        if isinstance(value, bool):
#          value = str(value).lower()
#        if ' ' in value:
#          value = f'"{value}"'
#        lines.append(f"\toption {key} '{value}'\n")
#    with open(self.file_path, 'w') as f:
#      f.writelines(lines)