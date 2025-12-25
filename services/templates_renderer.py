from jinja2 import Environment, FileSystemLoader

env = Environment(loader=FileSystemLoader("templates"))

template = env.from_string("Hello, {{ name }}!")
print(template.render(name="World"))