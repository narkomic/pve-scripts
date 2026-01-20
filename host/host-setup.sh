#!/usr/bin/env bash
set -Eeuo pipefail

SYSCTL_FILE="/etc/sysctl.d/98-community-scripts.conf"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run as root."
  exit 1
fi

if ! command -v pveversion >/dev/null 2>&1; then
  echo "This script is intended to run on a Proxmox VE host."
  exit 1
fi

cur_maxkeys="$(cat /proc/sys/kernel/keys/maxkeys 2>/dev/null || echo 0)"
cur_maxbytes="$(cat /proc/sys/kernel/keys/maxbytes 2>/dev/null || echo 0)"
if [[ "$cur_maxkeys" -le 0 || "$cur_maxbytes" -le 0 ]]; then
  echo "Unable to read current key limits from /proc/sys/kernel/keys/."
  exit 1
fi

new_maxkeys=$((cur_maxkeys * 2))
new_maxbytes=$((cur_maxbytes * 2))

echo "Host sysctl helper (kernel keyring limits)"
echo ""
echo "Current:"
echo "  kernel.keys.maxkeys=$cur_maxkeys"
echo "  kernel.keys.maxbytes=$cur_maxbytes"
echo ""
echo "Proposed (2x):"
echo "  kernel.keys.maxkeys=$new_maxkeys"
echo "  kernel.keys.maxbytes=$new_maxbytes"
echo ""
echo "Target file: $SYSCTL_FILE"
echo ""

if [[ -f "$SYSCTL_FILE" ]]; then
  echo "File already exists; leaving it unchanged."
  echo "Edit it manually if you want to apply the proposed values."
  exit 0
fi

read -r -p "Create $SYSCTL_FILE with the proposed values? [y/N] " ans
ans="${ans,,}"
if [[ "$ans" != "y" && "$ans" != "yes" ]]; then
  echo "Aborted."
  exit 0
fi

cat >"$SYSCTL_FILE" <<EOF
# pve-scripts / community-scripts compatible host sysctl
# This file must live on the Proxmox host (node), not inside any container.

kernel.keys.maxkeys=$new_maxkeys
kernel.keys.maxbytes=$new_maxbytes
EOF

echo "Wrote $SYSCTL_FILE"
echo "Apply with: sysctl --system"

