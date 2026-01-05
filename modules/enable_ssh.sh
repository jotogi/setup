#!/bin/bash
set -e

echo "[SSH] Enabling OpenSSH server..."

# Install OpenSSH server if not present
if ! dpkg -s openssh-server >/dev/null 2>&1; then
    echo "[SSH] Installing openssh-server..."
    sudo apt update
    sudo apt install -y openssh-server
else
    echo "[SSH] openssh-server already installed"
fi

# Ensure service enabled and started
sudo systemctl enable --now ssh

echo "[SSH] OpenSSH server enabled and running"

# Optional: show status (non-fatal)
sudo systemctl status ssh --no-pager || true

echo "[SSH] Done"
