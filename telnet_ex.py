from getpass4 import getpass
import telnetlib3.telnetlib as telnetlib

HOST = "<IP ADDRESS>"
user = input("Enter your remote account: ")
password = getpass("Password: ")

tn = telnetlib.Telnet(HOST)

tn.read_until(b"Username: ")
tn.write(user.encode('ascii') + b"\n")
if password:
    tn.read_until(b"Password: ")
    tn.write(password.encode('ascii') + b"\n")

tn.write(b"config t\n")
tn.write(b"interface loop 0\n")
tn.write(b"description This was added via python3\n")
tn.write(b"end\n")
tn.write(b"exit")

print(tn.read_all().decode('ascii'))

