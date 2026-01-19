#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Base updates
apt-get update
apt-get -y full-upgrade

# Docker prerequisites
apt-get install -y ca-certificates curl gnupg

install -m 0755 -d /etc/apt/keyrings

# Docker repo (Debian 13 = trixie)
curl -fsSL https://download.docker.com/linux/debian/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/debian trixie stable" \
> /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
systemctl enable --now docker

# Deploy Profilarr
mkdir -p /opt/profilarr/config
cat > /opt/profilarr/docker-compose.yml <<'YML'
services:
  profilarr:
    image: santiagosayshey/profilarr:latest
    container_name: profilarr
    ports:
      - "6868:6868"
    volumes:
      - /opt/profilarr/config:/config
    environment:
      - TZ=Europe/Copenhagen
    restart: unless-stopped
YML

cd /opt/profilarr
docker compose up -d
