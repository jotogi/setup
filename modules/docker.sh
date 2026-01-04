#!/bin/bash
set -e

echo "[Docker] Iniciant instal·lació..."

# Arquitectura
ARCH=$(dpkg --print-architecture || true)
echo "[Docker] Arquitectura detectada: ${ARCH:-unknown}"

# Eliminar paquets conflictius (no fallar si no existeixen)
sudo apt remove -y docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc || true

# Instal·lar prerequisits
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

# Configurar keyring i repositori Docker (segons docs oficials)
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

# Instal·lar Docker Engine i plugins recomanats
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Assegurar servei actiu
sudo systemctl enable --now docker

# Afegir usuari no-root al grup docker si s'executa amb sudo
if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
    sudo usermod -aG docker "$SUDO_USER" || true
    echo "[Docker] Afegit $SUDO_USER al grup docker (re-login per aplicar)"
fi

# Verificació bàsica (no fallar el script en cas d'error aquí)
if sudo docker run --rm hello-world >/dev/null 2>&1; then
    echo "[Docker] Prova 'hello-world' executada correctament"
else
    echo "[Docker] Avis: no s'ha pogut executar 'hello-world' (pot ser normal en alguns entorns)"
fi

echo "[Docker] Instal·lació completada"
