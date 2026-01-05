#!/bin/bash
set -e

echo "[Docker] Starting installation..."

# Architecture
ARCH=$(dpkg --print-architecture || true)
echo "[Docker] Detected architecture: ${ARCH:-unknown}"

# Remove conflicting packages (do not fail if they don't exist)
sudo apt remove -y docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc || true

# Install prerequisites
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

# Configure Docker keyring and APT repository (per official docs)
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null << EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

# Install Docker Engine and recommended plugins
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Ensure service is enabled and running
sudo systemctl enable --now docker

# Add non-root user to docker group if running via sudo
if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
    sudo usermod -aG docker "$SUDO_USER" || true
    echo "[Docker] Added $SUDO_USER to docker group (re-login required)"
fi

# Create docker group if it doesn't exist (for non-sudo installations)
if [ "${DOCKER_NONROOT_USER}" = true ] && ! getent group docker >/dev/null 2>&1; then
    sudo groupadd docker
    echo "[Docker] Created docker group"
    sudo usermod -aG docker "$USER" || true
    echo "[Docker] Added $USER to docker group (re-login required)"
    newgrp docker || true
    docker run hello-world >/dev/null 2>&1 && echo "[Docker] 'hello-world' test ran successfully as $USER" || echo "[Docker] Warning: could not run 'hello-world' as $USER (may be normal in some environments)"
fi


# Basic verification (do not fail the script on error here)
if sudo docker run --rm hello-world >/dev/null 2>&1; then
    echo "[Docker] 'hello-world' test ran successfully"
else
    echo "[Docker] Warning: could not run 'hello-world' (may be normal in some environments)"
fi

echo "[Docker] Installation completed"
