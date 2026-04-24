#!/usr/bin/env bash

HOST=$1
USER=$2

read -s -p "Enter sudo password for $USER@$HOST: " SUDOPASS
echo ""

echo "Connecting to $HOST as $USER..."

ssh -t "$USER@$HOST" "sudo -S bash" <<EOF
$SUDOPASS
set -euo pipefail
trap 'echo "Error occurred. Aborting."' ERR
set -x

echo "Creating user..."
id ansible >/dev/null 2>&1 || useradd -m -s /bin/bash ansible
usermod -aG wheel ansible

echo "Configuring SSH..."
mkdir -p /home/ansible/.ssh
chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh

echo "Setting sudo rules..."
[ -f /etc/sudoers.d/ansible ] || echo 'ansible ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible

echo "Done."
EOF