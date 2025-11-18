import pynetbox
import requests

class Connector:
    def __init__(self, NETBOX_URL, NETBOX_TOKEN, threading=True, strict_filters=True):
        self.nb = self.connect(NETBOX_URL, NETBOX_TOKEN, threading, strict_filters)

    def connect(self,NETBOX_URL, NETBOX_TOKEN, threading, strict_filters):
        adapter = TimeoutHTTPAdapter()
        session = requests.Session()
        session.mount("http://", adapter)
        session.mount("https://", adapter)
        nb = pynetbox.api(
            NETBOX_URL,
            NETBOX_TOKEN,
            threading,
            strict_filters,
        )
        nb.http_session = session
        return nb

class TimeoutHTTPAdapter(requests.adapters.HTTPAdapter):
    def __init__(self, *args, **kwargs):
        self.timeout = kwargs.get("timeout", 5)
        super().__init__(*args, **kwargs)

    def send(self, request, **kwargs):
        kwargs['timeout'] = self.timeout
        return super().send(request, **kwargs)