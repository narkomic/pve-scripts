#!/usr/bin/env bash
set -Eeuo pipefail

export DEBIAN_FRONTEND=noninteractive

if [[ -n "${FUNCTIONS:-}" ]]; then
  # shellcheck disable=SC1090
  source /dev/stdin <<<"$FUNCTIONS"
else
  RAW_BASE="${RAW_BASE:-https://raw.githubusercontent.com/narkomic/pve-scripts/main}"
  if command -v curl >/dev/null 2>&1; then
    # shellcheck disable=SC1090
    source <(curl -fsSL "${RAW_BASE}/misc/install.func")
  else
    echo "Missing FUNCTIONS and curl not found; cannot load framework."
    exit 127
  fi
fi

msg_info "Updating base system"
$STD apt-get update
$STD apt-get -y full-upgrade

msg_info "Installing Docker"
DOCKER_SKIP_UPDATES="true" setup_docker

# Deploy Profilarr
msg_info "Deploying Profilarr (Docker Compose)"
timezone="${tz:-UTC}"
mkdir -p /opt/profilarr/config
cat > /opt/profilarr/docker-compose.yml <<EOF
services:
  profilarr:
    image: santiagosayshey/profilarr:latest
    container_name: profilarr
    ports:
      - "6868:6868"
    volumes:
      - /opt/profilarr/config:/config
    environment:
      - TZ=$timezone
    restart: unless-stopped
EOF

cd /opt/profilarr
docker compose up -d

msg_ok "Installed Profilarr"
