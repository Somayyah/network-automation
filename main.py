#!/usr/bin/env python3

from dotenv import load_dotenv
import os
import pynetbox
import json

load_dotenv()

NETBOX_URL = os.getenv("NETBOX_URL")
NETBOX_TOKEN = os.getenv("NETBOX_TOKEN")

def main():
    pass

if __name__ == "__main__":
    nb = pynetbox.api(
        NETBOX_URL,
        token=NETBOX_TOKEN,
        threading=True,
        strict_filters=True,
    )
    
    devices = nb.dcim.devices.filter(device_role="cisco-switch")
    
    for d in devices:
        device_dict = dict(d)
        print(json.dumps(device_dict, indent=2))
    pass
