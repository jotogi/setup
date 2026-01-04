#!/bin/bash
set -e

echo "[Neovim] Iniciant mòdul..."

# ---------- SNAP ----------
if ! command -v snap >/dev/null 2>&1; then
    echo "[Neovim] snap no trobat — instal·lant snapd..."
    sudo apt update
    sudo apt install -y snapd
    sudo systemctl enable --now snapd.socket
    sudo ln -s /var/lib/snapd/snap /snap 2>/dev/null || true
    # esperar que snap estigui disponible
    for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
        if snap version >/dev/null 2>&1; then
            break
        fi
        sleep 1
    done
fi

if ! snap list | grep -q "^nvim"; then
    echo "[Neovim] Instal·lant Neovim..."
    sudo snap install nvim --classic
else
    echo "[Neovim] Neovim ja instal·lat"
fi

# ---------- CONFIG ----------
# Escriure la configuració en el directori de l'usuari real (si s'executa amb sudo)
if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
else
    USER_HOME="$HOME"
fi
NVIM_DIR="$USER_HOME/.config/nvim"
LUA_DIR="$NVIM_DIR/lua"

mkdir -p "$LUA_DIR"

# init.lua
[ -f "$NVIM_DIR/init.lua" ] || cat << 'EOF' > "$NVIM_DIR/init.lua"
require("options")
require("keymaps")
require("bootstrap")
EOF

# options.lua
[ -f "$LUA_DIR/options.lua" ] || cat << 'EOF' > "$LUA_DIR/options.lua"
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.termguicolors = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.clipboard = "unnamedplus"
opt.mouse = "a"
EOF

# keymaps.lua
[ -f "$LUA_DIR/keymaps.lua" ] || cat << 'EOF' > "$LUA_DIR/keymaps.lua"
vim.g.mapleader = " "
local map = vim.keymap.set
map("n", "<leader>w", "<cmd>w<cr>")
map("n", "<leader>q", "<cmd>q<cr>")
map("n", "<leader>h", "<cmd>nohlsearch<cr>")
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
EOF

# bootstrap.lua
[ -f "$LUA_DIR/bootstrap.lua" ] || cat << 'EOF' > "$LUA_DIR/bootstrap.lua"
-- reservat per plugins
EOF

# Si s'ha creat/actualitzat la configuració com root, restaurar propietari a l'usuari real
if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
    sudo chown -R "$SUDO_USER":"$SUDO_USER" "$NVIM_DIR" || true
fi

echo "[Neovim] Mòdul completat"
