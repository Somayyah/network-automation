#!/usr/bin/env bash

HOST=$1
USER=$2

echo "Connecting to $HOST as $USER..."

echo "Creating user..."
ssh "$USER@$HOST" <<EOF
useradd -m -s /bin/bash ansible
usermod -aG wheel ansible
EOF

echo "Configuring SSH..."
ssh "$USER@$HOST" <<EOF
mkdir -p /home/ansible/.ssh
chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh

# TBD...

EOF

echo "Setting sudo rules..."
ssh "$USER@$HOST" <<EOF
echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible
EOF

echo "Done."