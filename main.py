#!/usr/bin/env python3

from dotenv import load_dotenv
import os
from utils.connector import connector
import json

load_dotenv()

NETBOX_URL = os.getenv("NETBOX_URL")
NETBOX_TOKEN = os.getenv("NETBOX_TOKEN")

def main():
    conn = connector(NETBOX_URL,NETBOX_TOKEN)
    devices = conn.nb.dcim.devices.all()

    for d in devices:
        print(d)

if __name__ == "__main__":
    main()