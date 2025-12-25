#!/usr/bin/env python3

from dotenv import load_dotenv
import os
from utils.connector import Connector
import requests

def main():
    load_dotenv()

    NETBOX_URL = os.getenv("NETBOX_URL")
    NETBOX_TOKEN = os.getenv("NETBOX_TOKEN")

    conn = Connector(NETBOX_URL,NETBOX_TOKEN)

    try:
        devices = conn.nb.dcim.devices.filter(primary_ip="10.48.186.32/24")
        for d in devices:
            print(d)
    except requests.exceptions.ConnectTimeout as e:
        print(f"[ERROR] Connection timed out: {e}")
    except Exception as e:
        print(f"[ERROR] Something went wrong: {e}")

if __name__ == "__main__":
    main()