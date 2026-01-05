#!/bin/bash

# ===============================
# GENERAL SETUP CONFIGURATION
# ===============================

# ---------- NETWORK ----------
# Ethernet interface name to configure
NET_IFACE_NAME="eth0"
# Static IP address with CIDR notation
NET_STATIC_IP="192.168.1.26/24"
# Gateway IP address
NET_GATEWAY="192.168.1.1"
# DNS servers
NET_DNS_1="8.8.8.8"
NET_DNS_2="8.8.4.4"

# ---------- NETPLAN ----------
NETPLAN_ENABLE=false
# Netplan output file
# Change this if you prefer a different filename/path
NETPLAN_FILE="/etc/netplan/01-ethernet-static.yaml"

# ---------- SYSTEM ----------
# TIMEZONE="Europe/Madrid"
# LOCALE="ca_ES.UTF-8"

# ---------- NEOVIM ----------
# Set to true to install Neovim via snap, false to avoid installation
NVIM_ENABLE=false

# ---------- DOCKER ----------
# Set to true to install Docker Engine + docker-compose-plugin, false to avoid installation
DOCKER_ENABLE=false
