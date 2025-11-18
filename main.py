#!/usr/bin/env python3

from dotenv import load_dotenv
import os
from utils.connector import connector
import requests

def main():
    load_dotenv()

    NETBOX_URL = os.getenv("NETBOX_URL")
    NETBOX_TOKEN = os.getenv("NETBOX_TOKEN")

    try:
        conn = connector(NETBOX_URL,NETBOX_TOKEN)
        devices = conn.nb.dcim.devices.all()

        for d in devices:
            print(d)
    except requests.exceptions.ConnectionError as e:
        print(f"[ERROR] Could not connect to NetBox: {e}")
    except Exception as e:
        print(f"[ERROR] Something went wrong: {e}")

if __name__ == "__main__":
    main()