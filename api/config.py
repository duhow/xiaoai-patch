import os

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
