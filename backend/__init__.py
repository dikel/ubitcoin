import os

import pyqrcode
from bitcash import PrivateKeyTestnet # Replace
from backend.config import PRIVATE_KEY
from backend.config import QR

key = None

def get_address():
	return key.address

def get_display_address():
	return ':\n'.join(key.address.split(':'))
	
def key_exists():
	return os.path.exists(PRIVATE_KEY)
	
def create_path(filename):
    dirname = os.path.dirname(filename)
    if not os.path.exists(dirname):
        os.makedirs(dirname)
        
def get_qr():
	return QR
    
if key_exists():
	print('Debug: key exists')
	priv_key = open(PRIVATE_KEY, 'r')
	key = PrivateKeyTestnet(priv_key.read())
else:
	print('Debug: key does not exists')
	key = PrivateKeyTestnet()
	create_path(PRIVATE_KEY)
	priv_key = open(PRIVATE_KEY, 'w')
	priv_key.write(key.to_wif())
	priv_key.close()
	img = pyqrcode.create(key.address)
	img.svg(QR)
