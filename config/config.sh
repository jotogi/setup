#!/bin/bash

# ===============================
# GENERAL SETUP CONFIGURATION
# ===============================

# ---------- NETWORK ----------
NET_IFACE_NAME="eth0"
NET_STATIC_IP="192.168.1.26/24"
NET_GATEWAY="192.168.1.1"
NET_DNS_1="8.8.8.8"
NET_DNS_2="8.8.4.4"

# ---------- SYSTEM ----------
# TIMEZONE="Europe/Madrid"
# LOCALE="ca_ES.UTF-8"

# ---------- NEOVIM ----------
NVIM_ENABLE=true

# ---------- DOCKER ----------
# Set to true to install Docker Engine + docker-compose-plugin
DOCKER_ENABLE=false
