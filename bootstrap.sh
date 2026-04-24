#!/usr/bin/env bash

set -euo pipefail

HOST=$1
USER=$2

log() {
    echo "[+] $1"
}

step() {
    echo
    echo "==== $1 ===="
}

log "Preparing SSH key for ansible..."

timestamp=$(date +"%Y-%m-%d_%H_%M_%S")
KEY="$HOME/.ssh/ed25519_ansible_$timestamp"

ssh-keygen -C "ansible" -t ed25519 -f "$KEY" >/dev/null
PUBKEY=$(cat "${KEY}.pub")

log "Key generated: $KEY.pub"

step "Remote setup on $HOST"

read -s -p "Sudo password for $USER@$HOST: " SUDOPASS
echo

ssh -t "$USER@$HOST" "sudo -S bash" <<EOF
$SUDOPASS
set -euo pipefail

echo "[remote] Creating ansible user"
id ansible >/dev/null 2>&1 || useradd -m -s /bin/bash ansible
usermod -aG wheel ansible

echo "[remote] Configuring SSH directory"
install -d -m 700 -o ansible -g ansible /home/ansible/.ssh

echo "[remote] Installing authorized key"
echo "$PUBKEY" >> /home/ansible/.ssh/authorized_keys
chown ansible:ansible /home/ansible/.ssh/authorized_keys
chmod 600 /home/ansible/.ssh/authorized_keys

echo "[remote] Configuring sudo rules"
if [ ! -f /etc/sudoers.d/ansible ]; then
    echo 'ansible ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/ansible
    chmod 440 /etc/sudoers.d/ansible
fi

echo "[remote] Setup complete"
EOF

step "Local SSH agent setup"

ssh-add "$KEY"
log "Key added to SSH agent"