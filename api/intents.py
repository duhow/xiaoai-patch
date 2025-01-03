from flask import Blueprint, request, jsonify
import yaml
import os

intents = Blueprint('intents', __name__)

intents_file = os.path.join(os.path.dirname(__file__), 'intents.yaml')
intents_data = yaml.load(open(intents_file, 'r'), Loader=yaml.FullLoader)

def remove_accents(input: str) -> str:
  characters = {
    'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
    'à': 'a', 'è': 'e', 'ì': 'i', 'ò': 'o', 'ù': 'u',
  }
  
  for char, repl in characters.items():
    input = input.replace(char, repl)
  return input

@intents.post('/intent')
def get_intents():
  text = None
  if request.is_json:
    data = request.get_json()
    text = data.get('text', '').strip()
  else:
    text = request.form.get('text', '').strip()
  if not text:
    return jsonify({'error': 'No text provided'}), 400
  
  accepts_json = request.headers.get('Accept') == 'application/json'
  
  text = text.lower()
  text = remove_accents(text)
  for char in ['.', ',', '?', '!', ':', ';']:
    text = text.replace(char, '')

  for word, replacements in intents_data.get('replaces', {}).items():
    for replacement in replacements:
      if text == replacement:
        text = word
        break
      elif f' {replacement} ' in text:
        text = text.replace(f' {replacement} ', f' {word} ')
      elif f'{replacement} ' in text:
        text = text.replace(f'{replacement} ', f'{word} ')
      elif text.endswith(replacement):
        text = text[:len(text)-len(replacement)] + word

  for entry in intents_data['intents']:
    if text in entry['sentences']:
      if accepts_json:
        return jsonify({'intent': entry['action']})
      return entry['action'] + '\n'
  if accepts_json:
    return jsonify({'intent': ''}), 404
  return "", 404