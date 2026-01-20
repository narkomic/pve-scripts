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
  elif command -v wget >/dev/null 2>&1; then
    # shellcheck disable=SC1090
    source <(wget -qO- "${RAW_BASE}/misc/install.func")
  else
    echo "Missing dependency: curl or wget is required."
    exit 127
  fi
fi

msg_info "Starting install"

# Example:
# $STD apt-get update
# $STD apt-get install -y <packages>

msg_ok "Install completed"
