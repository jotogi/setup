#!/bin/bash
set -e

echo "[Netplan] Iniciant configuració Ethernet..."

# ---------- VALIDACIÓ DE VARIABLES ----------
: "${NET_IFACE_NAME:?❌ NET_IFACE_NAME no definida}"
: "${NET_STATIC_IP:?❌ NET_STATIC_IP no definida}"
: "${NET_GATEWAY:?❌ NET_GATEWAY no definida}"
: "${NET_DNS_1:?❌ NET_DNS_1 no definida}"
: "${NET_DNS_2:?❌ NET_DNS_2 no definida}"

# Validació bàsica de format IP/CIDR
if [[ ! "$NET_STATIC_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]]; then
    echo "❌ NET_STATIC_IP no té format IP/CIDR (ex: 192.168.1.26/24)"
    exit 1
fi

echo "[Netplan] Variables validades correctament"

# ---------- DETECTAR INTERFÍCIE FÍSICA ----------
ETH_IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^eth|^en' | head -n 1)

if [ -z "$ETH_IFACE" ]; then
    echo "❌ No s'ha detectat cap interfície ethernet"
    exit 1
fi

MAC_ADDR=$(cat /sys/class/net/$ETH_IFACE/address)

echo "[Netplan] Interfície detectada: $ETH_IFACE"
echo "[Netplan] MAC detectada: $MAC_ADDR"

# ---------- ESCRIURE NETPLAN ----------
NETPLAN_FILE="/etc/netplan/01-ethernet-static.yaml"

sudo tee "$NETPLAN_FILE" > /dev/null << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $NET_IFACE_NAME:
      match:
        macaddress: $MAC_ADDR
      set-name: $NET_IFACE_NAME
      dhcp4: no
      addresses:
        - $NET_STATIC_IP
      gateway4: $NET_GATEWAY
      nameservers:
        addresses:
          - $NET_DNS_1
          - $NET_DNS_2
EOF

echo "[Netplan] Aplicant configuració..."
sudo netplan apply

echo "[Netplan] ✅ Xarxa configurada correctament"
