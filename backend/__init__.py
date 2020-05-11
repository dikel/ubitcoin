import os
import json
from functools import reduce

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
	#BitpayRates.currency_to_satoshi('usd')
	key.get_balance()
	return key.balance_as('bch'), key.balance_as(fiat)

def get_all_transaction_ids():
	return key.get_transactions()

def get_transaction_details(id):
	transaction = NetworkAPI.get_transaction_testnet(id) # Remove testnet
	is_sent = key.address in list(map(lambda txin: txin.address, transaction.inputs))
	address = None
	amount = None
	if is_sent:
		address = list(map(lambda txout: txout.address, transaction.outputs))[0]
		amount = '{:f}'.format(transaction.outputs[0].amount + transaction.amount_fee)
	else:
		address = list(map(lambda txin: txin.address, transaction.inputs))[0]
		amount = '{:f}'.format(next(txout.amount for txout in transaction.outputs if txout.address == key.address))

	amount = satoshi_to_currency_cached(int(amount), 'bch')
	tx = {'id': transaction.txid,
		'inputs': list(map(lambda txin: '{:f}'.format(txin.amount), transaction.inputs)),
		'outputs': list(map(lambda txout: '{:f}'.format(txout.amount), transaction.outputs)),
		'is_sent': is_sent,
		'address': address,
		'amount': amount}
	jsontx = json.dumps(tx)
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
