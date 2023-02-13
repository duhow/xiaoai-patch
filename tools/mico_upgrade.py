#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from base64 import b64encode
import hashlib
from time import time
import requests
import sys

def md5(data):
    m = hashlib.md5()
    if isinstance(data, str):
        data = data.encode('utf-8')
    m.update(data)
    return m.hexdigest()

def base64(data):
    if isinstance(data, str):
        data = data.encode('utf-8')
    return b64encode(data)

salt = '00000050-b1f4-4e93-afe1-8b967ddcf9cc'
model = 'lx06'
channel = 'release'
version = '1.50.1'
if len(sys.argv) >= 2:
    model = sys.argv[1]
if len(sys.argv) >= 3 and sys.argv[2] in ['current', 'stable', 'release']:
    channel = sys.argv[2]
if len(sys.argv) >= 4:
    version = sys.argv[3]
host = 'api.miwifi.com'
now = int(time())
request = {
    'channel': channel,
    'countryCode': 'WW',
    'filterID': '1234567',
    'locale': 'zh_CN',
    'time': now,
    'version': version
}
# format to URL query
request = "&".join([f'{k}={v}' for k, v in request.items()])
sig = md5(base64(f'{request}&{salt}'))

query = f's={sig}&time={now}&{request}'
url = f'https://{host}/rs/grayupgrade/v2/{model}/thirdparty?{query}'

print(url)
update = requests.get(url)
print(update.text)
update.raise_for_status()
