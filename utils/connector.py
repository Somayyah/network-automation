import pynetbox

class connector:
    def __init__(self, NETBOX_URL, NETBOX_TOKEN, threading=True, strict_filters=True):
        self.NETBOX_URL = NETBOX_URL
        self.NETBOX_TOKEN = NETBOX_TOKEN
        self.threading = threading
        self.strict_filters = strict_filters
        self.nb = pynetbox.api(
            self.NETBOX_URL,
            token=self.NETBOX_TOKEN,
            threading=self.threading,
            strict_filters=self.strict_filters,
        )
