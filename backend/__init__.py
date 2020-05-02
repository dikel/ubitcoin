import os
import json

import pyqrcode
from bitcash import PrivateKeyTestnet # Replace
from bitcash.network import currency_to_satoshi_cached
from bitcash.network import satoshi_to_currency_cached
from bitcash.network import NetworkAPI
from cashaddress import convert

from backend.config import PRIVATE_KEY
from backend.config import QR

key = None

def get_address():
	return key.address, QR
	
def key_exists():
	return os.path.exists(PRIVATE_KEY)
	
def create_path(filename):
    dirname = os.path.dirname(filename)
    if not os.path.exists(dirname):
        os.makedirs(dirname)
	
def get_balance(fiat='usd'):
	key.get_balance()
	return key.balance_as('bch'), key.balance_as(fiat)
	
def get_transactions():
	tx1 = NetworkAPI.get_transaction_testnet(key.get_transactions()[0]) # Remove testnet
	tx = {'id': tx1.txid, 'block': tx1.block }
	jsontx = json.dumps(tx)
	print(jsontx)
	return jsontx
	
def bch_to_fiat(amount, fiat='usd'):
	satoshi = currency_to_satoshi_cached(amount, 'bch')
	return satoshi_to_currency_cached(satoshi, fiat)
	
def fiat_to_bch(amount, fiat='usd'):
	satoshi = currency_to_satoshi_cached(amount, fiat)
	return satoshi_to_currency_cached(satoshi, 'bch')
	
def is_address_valid(address):
	return convert.is_valid(address)
	
def send(address, amount):
	outputs = [
		(address, amount, 'bch'),
	]
	try:
		return key.send(outputs)
	except:
		return false
    
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
