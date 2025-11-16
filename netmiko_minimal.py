from netmiko import ConnectHandler

router1 = {
    "device_type": "<VENDOR>",
    "host": "<IP ADDRESS>", 
    "username": "<USERNAME>",
    "password": "<PASSWORD>",
}

net_connect = ConnectHandler(**router1) 

output = net_connect.send_command("show ip int brief")
print(output)
