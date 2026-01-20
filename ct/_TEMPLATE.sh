#!/usr/bin/env bash

RAW_BASE="${RAW_BASE:-https://raw.githubusercontent.com/narkomic/pve-scripts/main}"
if command -v curl >/dev/null 2>&1; then
  source <(curl -fsSL "${RAW_BASE}/misc/build.func")
elif command -v wget >/dev/null 2>&1; then
  source <(wget -qO- "${RAW_BASE}/misc/build.func")
else
  echo "Missing dependency: curl or wget is required."
  exit 127
fi

APP="MyApp"

# Optional metadata for PVE tags (shown in Proxmox UI)
var_tags="${var_tags:-}"

# Container defaults (can be overridden via default.vars / app vars / env)
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-8}"

# Template OS
var_os="${var_os:-debian}"
var_version="${var_version:-12}"

# Container type: 1=unprivileged, 0=privileged
var_unprivileged="${var_unprivileged:-1}"

# Installer script name (install/<name>.sh without .sh)
var_install="${var_install:-myapp-install}"

header_info
variables
start
build_container
description

msg_ok "Completed Successfully!"
