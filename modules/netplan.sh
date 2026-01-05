#!/bin/bash
set -e

echo "[Netplan] Starting Ethernet configuration..."

# ---------- VARIABLE VALIDATION ----------
: "${NET_IFACE_NAME:?❌ NET_IFACE_NAME not defined}"
: "${NET_STATIC_IP:?❌ NET_STATIC_IP not defined}"
: "${NET_GATEWAY:?❌ NET_GATEWAY not defined}"
: "${NET_DNS_1:?❌ NET_DNS_1 not defined}"
: "${NET_DNS_2:?❌ NET_DNS_2 not defined}"

# Basic IP/CIDR format validation
if [[ ! "$NET_STATIC_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]]; then
  echo "❌ NET_STATIC_IP does not have IP/CIDR format (e.g. 192.168.1.26/24)"
  exit 1
fi

echo "[Netplan] Variables validated successfully"

# ---------- DETECT PHYSICAL INTERFACE ----------
ETH_IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^eth|^en' | head -n 1)

if [ -z "$ETH_IFACE" ]; then
    echo "❌ No ethernet interface detected"
    exit 1
fi

MAC_ADDR=$(cat /sys/class/net/$ETH_IFACE/address)

echo "[Netplan] Detected interface: $ETH_IFACE"
echo "[Netplan] Detected MAC: $MAC_ADDR"

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

echo "[Netplan] Applying configuration..."
sudo netplan apply

echo "[Netplan] ✅ Network configured successfully"
