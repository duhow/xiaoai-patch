from flask import Flask, jsonify, request
import os
import re

hostname = os.uname()[1]
app = Flask(__name__)

services_dir = '/etc/init.d'

@app.route('/')
def info():
  return jsonify({'hostname': hostname})

@app.route('/services')
def list_services():
  ignored_list = ['boot', 'coredump', 'done', 'led', 'silentboot']
  files = [f for f in os.listdir(services_dir) if os.access(os.path.join(services_dir, f), os.X_OK) and f not in ignored_list]
  return jsonify({'data': {'services': files}})

@app.route('/services/<service>/<action>')
def manage_service(service, action):
  action = action.lower().strip()
  service_path = os.path.join(services_dir, service)
  if not os.path.exists(service_path) or not os.access(service_path, os.X_OK):
    return jsonify({'error': 'Service not found or not executable'}), 404

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
    with open('/sys/ir_tx_gpio/ir_data', 'w') as f:
      f.write(code)
  except IOError as e:
    return jsonify({'error': f'Failed to send infrared signal: {e}'}), 500

  return jsonify({}), 200

if __name__ == '__main__':
  app.run(debug=False, host='0.0.0.0', port=80)
