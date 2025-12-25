from jinja2 import Environment, FileSystemLoader
from json import load

env = Environment(loader=FileSystemLoader("services/templates/"))

params = {}

with open("services/params.json", "r") as p:
    params = load(p)

template = env.get_template("tacacs.j2")

servers = params["tacacs-servers"]
SECRET = servers["secret"]
TACACS_IP = []
for srv in servers["IPs"]:
    TACACS_IP.append(srv)

with open("services/rendered/tacacs.txt", "w") as w:
    w.write(template.render(TACACS_IP=TACACS_IP, SECRET=SECRET))