import paramiko

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

client.connect(
    "<IP address of NAD>",
    username="<USERNAME>",
    password="<PASSWORD>",
    look_for_keys=False,
    allow_agent=False,
    auth_timeout=20
)

stdin, stdout, stderr = client.exec_command("show version")
print(stdout.read().decode())
client.close()

