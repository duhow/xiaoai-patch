from flask import Flask, jsonify
import os

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
  action = action.lower().trim()
  service_path = os.path.join(services_dir, service)
  if not os.path.exists(service_path) or not os.access(service_path, os.X_OK):
    return jsonify({'error': 'Service not found or not executable'}), 404

  if action not in ['start', 'stop', 'restart']:
    return jsonify({'error': 'Invalid action'}), 400

  result = os.system(f'{service_path} {action}')
  if result != 0:
    return jsonify({'error': f'Failed to {action} service'}), 500

  return jsonify({'message': f'Service {service} {action}ed successfully'})

if __name__ == '__main__':
  app.run(debug=False, host='0.0.0.0', port=80)