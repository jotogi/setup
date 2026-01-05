#!/bin/bash
set -e

echo "=============================="
echo "  UBUNTU RASPBERRY PI 4 SETUP "
echo "=============================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"

# ---------- CONFIG ----------
source "$SCRIPT_DIR/config/config.sh"

# ---------- MÒDULS ----------

# ---------- NETPLAN ---------
if [ "${NETPLAN_ENABLE:-false}" = true ]; then
	source "$MODULES_DIR/netplan.sh"
else
	echo "[Netplan] Skipping Ethernet configuration (NETPLAN_ENABLE=false)"
fi

# ---------- NEOVIM ----------
if [ "${NVIM_ENABLE:-false}" = true ]; then
	source "$MODULES_DIR/neovim.sh"
else
	echo "[Neovim] Skipping installation (NVIM_ENABLE=false)"
fi

# ---------- DOCKER ----------
if [ "${DOCKER_ENABLE:-false}" = true ]; then
	source "$MODULES_DIR/docker.sh"
else
	echo "[Docker] Skipping installation (DOCKER_ENABLE=false)"
fi

echo "✅ Setup completed successfully"
