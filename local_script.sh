#!/bin/bash
set -euo pipefail

# local_script.sh
# Generate an ed25519 SSH key and deploy the public key to the host at NET_STATIC_IP

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config/config.sh"

# Extract IP (strip CIDR if present)
TARGET_IP="${NET_STATIC_IP%%/*}"

# Default remote user
read -rp "Remote user [${USER}]: " REMOTE_USER_INPUT
REMOTE_USER="${REMOTE_USER_INPUT:-$USER}"

KEY_NAME="id_ed25519_rpi_setup"
KEY_PATH="$HOME/.ssh/$KEY_NAME"

mkdir -p "$HOME/.ssh"

if [ -f "$KEY_PATH" ] || [ -f "$KEY_PATH.pub" ]; then
  read -rp "Key $KEY_PATH exists. Overwrite? [y/N]: " ans
  case "$ans" in
    [Yy]*) rm -f "$KEY_PATH" "$KEY_PATH.pub" ;;
    *) echo "Aborting."; exit 1 ;;
  esac
fi

echo "Generating SSH key pair at $KEY_PATH..."
ssh-keygen -t ed25519 -f "$KEY_PATH" -N "" -C "setup@$TARGET_IP"
chmod 600 "$KEY_PATH"
chmod 644 "$KEY_PATH.pub"

# Deploy public key
if command -v ssh-copy-id >/dev/null 2>&1; then
  echo "Using ssh-copy-id to deploy public key to $REMOTE_USER@$TARGET_IP..."
  ssh-copy-id -i "$KEY_PATH.pub" "$REMOTE_USER@$TARGET_IP"
else
  echo "ssh-copy-id not found, using manual deployment..."
  # ensure remote .ssh exists and has correct perms
  ssh "$REMOTE_USER@$TARGET_IP" "mkdir -p ~/.ssh && chmod 700 ~/.ssh || true"
  cat "$KEY_PATH.pub" | ssh "$REMOTE_USER@$TARGET_IP" "cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
fi

# Quick connection test (non-interactive)
if ssh -o BatchMode=yes -o ConnectTimeout=5 "$REMOTE_USER@$TARGET_IP" 'echo ok' >/dev/null 2>&1; then
  echo "Passwordless SSH setup succeeded: $REMOTE_USER@$TARGET_IP"
else
  echo "Warning: SSH test failed — you may need to accept the host key or check credentials. Try: ssh $REMOTE_USER@$TARGET_IP"
fi
