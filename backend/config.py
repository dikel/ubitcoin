import os

DIR = os.path.abspath(os.path.curdir)
APP_ID = "ubitcoin.ixerious"

if os.environ.get('XDG_DATA_HOME'):
    DIR = os.path.join(os.environ['XDG_DATA_HOME'], APP_ID)

QR = os.path.join(DIR, "qr.svg")
PRIVATE_KEY = os.path.join(DIR, "key.txt")
