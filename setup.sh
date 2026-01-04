#!/bin/bash
set -e

echo "=============================="
echo "  SETUP UBUNTU RASPBERRY PI 4 "
echo "=============================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"

# ---------- CONFIG ----------
source "$SCRIPT_DIR/config/config.sh"

# ---------- MÒDULS ----------

# ---------- NETPLAN ---------
source "$MODULES_DIR/netplan.sh"

# ---------- NEOVIM ----------
source "$MODULES_DIR/neovim.sh"

echo "✅ Setup completat correctament"
