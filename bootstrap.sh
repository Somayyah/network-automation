#!/usr/bin/env bash

set -euo pipefail

## Validate arguments

HOST=${1:-}
USER=${2:-}
GH_EMAIL=${3:-}

if [[ -z "$HOST" ]]; then
    read -rp "Target host: " HOST
fi
if [[ -z "$USER" ]]; then
    read -rp "Remote user: " USER
fi
if [[ -z "$GH_EMAIL" ]]; then
    read -rp "GitHub email address: " GH_EMAIL
fi

log() {
    echo "[+] $1"
}

step() {
    echo
    echo "==== $1 ===="
}

## SSH
step "Generating SSH keys"

log "Preparing SSH key for ansible..."

timestamp=$(date +"%Y-%m-%d_%H_%M_%S")
KEY="$HOME/.ssh/ed25519_ansible_$timestamp"
GH_KEY="$HOME/.ssh/ed25519_gh_$timestamp"

ssh-keygen -C "ansible" -t ed25519 -f "$KEY" -N "" >/dev/null
ssh-keygen -C "${GH_EMAIL}" -t ed25519 -f "$GH_KEY" -N "" >/dev/null

PUBKEY=$(cat "${KEY}.pub")
GH_PUBKEY=$(cat "${GH_KEY}.pub")
log "Ansible key generated: $KEY.pub"
log "GitHub key generated: ${GH_KEY}.pub"

## GH

step "GitHub SSH key"

echo
echo "  Add this public key to GitHub > Settings > SSH and GPG keys:"
echo
echo "$GH_PUBKEY"
echo

while true; do
    read -rp "Have you added the key to GitHub? [y/N]: " GH_DONE
    case "$GH_DONE" in
        [yY]) break ;;
        *)    log "Waiting — please add the key to GitHub before continuing." ;;
    esac
done

## Vault

step "Vault GitHub SSH key for Ansible"

ANSIBLE_VARS="ansible/vars/main.yaml"

if ! command -v ansible-vault &>/dev/null; then
    log "ansible-vault not found — skipping vault step"
    log "Manually vault the key later:"
    log "  ansible-vault encrypt_string --stdin-name 'github_ssh_key' < $GH_KEY >> $ANSIBLE_VARS"
else
    read -s -rp "Enter ansible-vault password: " VAULT_PASS
    echo
    read -s -rp "Confirm ansible-vault password: " VAULT_PASS_CONFIRM
    echo

    if [[ "$VAULT_PASS" != "$VAULT_PASS_CONFIRM" ]]; then
        log "Vault passwords do not match — skipping. Encrypt manually:"
        log "  ansible-vault encrypt_string --stdin-name 'github_ssh_key' < $GH_KEY >> $ANSIBLE_VARS"
    else
        VAULT_PASS_FILE=$(mktemp)
        echo "$VAULT_PASS" > "$VAULT_PASS_FILE"

        ansible-vault encrypt_string \
            --vault-password-file "$VAULT_PASS_FILE" \
            --stdin-name "github_ssh_key" \
            < "$GH_KEY" >> "$ANSIBLE_VARS"

        rm -f "$VAULT_PASS_FILE"
        log "GitHub key appended to $ANSIBLE_VARS as vaulted variable"
    fi
fi

GH_PRIVATE_KEY=$(cat "$GH_KEY")
## Remote setup

step "Remote setup on $HOST"

read -s -rp "Sudo password for $USER@$HOST: " SUDOPASS
echo

ssh -t "$USER@$HOST" "sudo -S bash -s" <<< "$SUDOPASS
$(cat <<EOF
set -euo pipefail

echo "[remote] Creating ansible user"
id ansible >/dev/null 2>&1 || useradd -m -s /bin/bash ansible
usermod -aG wheel ansible

echo "[remote] Configuring SSH directory"
install -d -m 700 -o ansible -g ansible /home/ansible/.ssh

echo "[remote] Installing authorized key"
grep -qxF "$PUBKEY" /home/ansible/.ssh/authorized_keys || \
echo "$PUBKEY" >> /home/ansible/.ssh/authorized_keys
chown ansible:ansible /home/ansible/.ssh/authorized_keys
chmod 600 /home/ansible/.ssh/authorized_keys

echo "[remote] Configuring sudo rules"
if [ ! -f /etc/sudoers.d/ansible ]; then
    echo 'ansible ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/ansible
    chmod 440 /etc/sudoers.d/ansible
fi

echo "[remote] Setting up GitHub SSH for $USER"

install -d -m 700 -o $USER -g $USER /home/$USER/.ssh

cat > /home/$USER/.ssh/id_ed25519_github <<KEY
$GH_PRIVATE_KEY
KEY

chmod 600 /home/$USER/.ssh/id_ed25519_github
chown $USER:$USER /home/$USER/.ssh/id_ed25519_github

cat > /home/$USER/.ssh/config <<CFG
Host github.com
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes
CFG

chmod 600 /home/$USER/.ssh/config
chown $USER:$USER /home/$USER/.ssh/config

echo "[remote] Trusting GitHub host key"
ssh-keygen -F github.com -f /home/$USER/.ssh/known_hosts >/dev/null || \
ssh-keyscan github.com >> /home/$USER/.ssh/known_hosts
chown $USER:$USER /home/$USER/.ssh/known_hosts
chmod 600 /home/$USER/.ssh/known_hosts

echo "[remote] Setup complete"
EOF
)"

# Plaintext key is now vaulted — delete it from the bootstrap machine
rm -f "$GH_KEY" "${GH_KEY}.pub"
log "Plaintext GitHub key deleted from local machine"

## Local SSH agent

step "Local SSH agent setup"

ssh-add "$KEY"
log "Ansible key added to SSH agent"

## Done

step "Bootstrap complete"
log "Next step: make setup"