from flask import Flask, jsonify, request, redirect
import os
import re
import requests
import subprocess

from config import ConfigManager
from utils import get_ip_address
import const

hostname = os.uname()[1]
speaker_ip = get_ip_address('wlan0')
app = Flask(__name__)

config = ConfigManager(const.config_listener)

@app.route('/')
def index():
  return app.send_static_file('index.html')

@app.get('/discover')
def info():
  service_search_name = '_home-assistant._tcp'
  def parse_avahi_output(output):
    instances = list()
    for line in output.split('\n'):
      if service_search_name in line and 'IPv4' in line:
        parts = line.split(';')
        if len(parts) > 7:
          service_name = parts[3]
          txt_records = parts[9]
          txt_dict = {}
          for txt in re.findall(r'"(.*?)"', txt_records):
            if '=' in txt:
              key, val = txt.split('=', 1)
              if val == 'True':
                val = True
              if val == 'False':
                val = False
              txt_dict[key] = val
          instances.append(txt_dict)
    return instances

  try:
    result = subprocess.run(f'avahi-browse -rpt {service_search_name}'.split(' '), capture_output=True, text=True)
    if result.returncode == 0:
      instances = parse_avahi_output(result.stdout)
      return jsonify({'hostname': hostname, 'instances': instances})
    else:
      return jsonify({'hostname': hostname, 'instances': []}), 500
  except Exception as e:
    return jsonify({'hostname': hostname, 'error': str(e)}), 500

@app.post('/auth')
def home_assistant_auth():
  ha_url = request.form.get('url', '').rstrip('/')
  if not ha_url or not ha_url.startswith('http'):
    return jsonify({'error': 'Missing url parameter'}), 400

  if config.HA_URL == ha_url and config.HA_TOKEN and len(config.HA_TOKEN) > 30:
    return jsonify({'message': 'Instance already configured'})

  config.HA_URL = ha_url
  config.HA_TOKEN = "none"

  data = {
    'client_id': f'http://{speaker_ip}',
    'redirect_uri': f'http://{speaker_ip}/auth_callback',
  }

  query_params = '&'.join([f'{key}={value}'.replace(':','%3A').replace('/','%2F') for key, value in data.items()])
  return redirect(f'{ha_url}/auth/authorize?{query_params}', code=303)

# https://developers.home-assistant.io/docs/auth_api/
@app.get('/auth_callback')
def home_assistant_auth_callback():
  code = request.args.get('code')
  store_token = request.args.get('storeToken', 'false').lower() == 'true'
  state = request.args.get('state')

  if not code:
    return jsonify({'error': 'Missing code parameter'}), 400

  data = {
    'grant_type': 'authorization_code',
    'code': code,
    'client_id': f'http://{speaker_ip}',
  }

  headers = {
    'Content-Type': 'application/x-www-form-urlencoded'
  }

  ha_url = config.HA_URL
  if not ha_url:
    return jsonify({'error': 'Home Assistant URL not configured'}), 500

  req = requests.post(f'{ha_url}/auth/token', data=data, headers=headers)

  if req.status_code != 200:
    return jsonify({'error': 'Failed to get access token', 'code': req.status_code, 'response': req.json()}), 500

  token = req.json()
  if store_token:
    config.HA_TOKEN = token['access_token']
    config.HA_REFRESH_TOKEN = token['refresh_token']

  return jsonify({'message': 'Auth configured'})

def home_assistant_refresh_token():
  ha_url = config.HA_URL
  if not ha_url:
    return False

  data = {
    'grant_type': 'refresh_token',
    'refresh_token': config.HA_REFRESH_TOKEN,
  }

  headers = {
    'Content-Type': 'application/x-www-form-urlencoded'
  }

  req = requests.post(f'{ha_url}/auth/token', data=data, headers=headers)

  if req.status_code != 200:
    return False

  token = req.json()
  config.HA_TOKEN = token['access_token']

  return True

@app.route('/services')
def list_services():
  files = [f for f in os.listdir(const.services_dir) if os.access(os.path.join(const.services_dir, f), os.X_OK) and f in const.services_allowed]
  return jsonify({'data': {'services': files}})

@app.route('/services/<service>/<action>')
def manage_service(service, action):
  action = action.lower().strip()
  service_path = os.path.join(const.services_dir, service)
  if not os.path.exists(service_path) or not os.access(service_path, os.X_OK):
    return jsonify({'error': 'Service not found or not executable'}), 404

  if service not in const.services_allowed:
    return jsonify({'error': 'Service not allowed'}), 403

  if action not in ['start', 'stop', 'restart']:
    return jsonify({'error': 'Invalid action'}), 400

  result = os.system(f'{service_path} {action}')
  if result != 0:
    return jsonify({'error': f'Failed to {action} service'}), 500

  return jsonify({'message': f'Service {service} {action}ed successfully'})

@app.get('/ir')
def send_infrared():
  code = request.args.get('code')
  carrier = request.args.get('carrier')

  # TODO: check model
  if not hostname.lower().startswith('lx06'):
    return jsonify({'error': 'Infrared not supported on this model'}), 415

  if not code:
    return jsonify({'error': 'Missing code or carrier parameter'}), 400

  code = code.strip().replace('+', ' ').replace(' ', ',')
  if not re.match(r'^[0-9,-]+$', code):
    return jsonify({'error': 'Invalid code format'}), 400

  try:
    with open(const.lx06_infrared, 'w') as f:
      f.write(code)
  except IOError as e:
    return jsonify({'error': f'Failed to send infrared signal: {e}'}), 500

  return jsonify({}), 200

if __name__ == '__main__':
  app.run(debug=False, host='0.0.0.0', port=80)
