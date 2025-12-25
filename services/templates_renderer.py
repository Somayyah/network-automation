from jinja2 import Environment, FileSystemLoader

env = Environment(loader=FileSystemLoader("services/templates/"))

template = env.get_template("tacacs.j2")

print(template.render(TACACS_IP="10.0.0.1", SECRET="cisco"))