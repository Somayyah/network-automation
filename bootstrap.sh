#!/usr/bin/env bash

HOST=$1
USER=$2

echo "Preparing the SSH Public Key Authentication..."
timestamp=$(date +"%Y-%m-%d_%H_%M_%S")

ssh-keygen -C "ansible" -t ed25519 -f "$HOME/.ssh/ed25519_ansible_$timestamp"
PUBKEY=$(cat ~/.ssh/ed25519_ansible_$timestamp.pub)

echo "Connecting to $HOST as $USER..."

read -s -p "Enter sudo password for $USER@$HOST: " SUDOPASS
echo ""

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

echo "adding the public key..."
echo "$PUBKEY" >> /home/ansible/.ssh/authorized_keys
chown ansible:ansible /home/ansible/.ssh/authorized_keys
chmod 600 /home/ansible/.ssh/authorized_keys

echo "Setting sudo rules..."
[ -f /etc/sudoers.d/ansible ] || echo 'ansible ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible

echo "Done."
EOF

ssh-add "$HOME/.ssh/ed25519_ansible_$timestamp"