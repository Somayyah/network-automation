from jinja2 import Environment, FileSystemLoader
from json import load

env = Environment(loader=FileSystemLoader("services/templates/"))

params = {}

with open("params.json", "r") as p:
    params = p.load()

template = env.get_template("tacacs.j2")

servers = params["tacacs-servers"]
SECRET = servers["secret"]
TACACS_IP = []
for srv in servers["IPs"]:
    TACACS_IP.append(srv)

template.render(TACACS_IP=TACACS_IP, SECRET=SECRET)