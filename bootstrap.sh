#!/usr/bin/env bash

HOST=$1
USER=$2

ssh "$USER@$HOST" <<EOF
useradd -m -s /bin/bash ansible
usermod -aG wheel ansible
mkdir -p /home/ansible/.ssh
EOF

# ssh-copy-id "ansible@$HOST"