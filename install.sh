#!/usr/bin/env bash
set -Eeuo pipefail

# Minimal upstream-like entrypoint:
# - Run one command on the Proxmox host
# - Pick an app from a menu
# - Executes the selected CT script from *this* repo

RAW_BASE="${RAW_BASE:-https://raw.githubusercontent.com/narkomic/pve-scripts/main}"

_fetch() {
  local url="$1"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$url"
  else
    echo "Missing dependency: curl or wget is required."
    exit 127
  fi
}

if ! command -v pveversion >/dev/null 2>&1; then
  echo "Run this on a Proxmox VE host."
  exit 1
fi

APP_LIST="$(_fetch "${RAW_BASE}/misc/app-list.txt")"
if [[ -z "${APP_LIST//[[:space:]]/}" ]]; then
  echo "No apps found (misc/app-list.txt is empty or missing)."
  exit 1
fi

declare -a MENU_ITEMS=()
while IFS='|' read -r name path desc tags; do
  [[ -z "${name:-}" ]] && continue
  [[ "${name:0:1}" == "#" ]] && continue
  MENU_ITEMS+=("$name" "${desc:- }")
done <<<"$APP_LIST"

if command -v whiptail >/dev/null 2>&1; then
  CHOICE=$(whiptail --backtitle "Proxmox VE Helper Scripts" \
    --title "pve-scripts" \
    --ok-button "Install" --cancel-button "Exit" \
    --menu "\nChoose an app to install from:\n${RAW_BASE}\n" 18 70 10 \
    "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3) || exit 0
else
  echo "whiptail not found; falling back to text selection."
  i=1
  while IFS='|' read -r name path desc tags; do
    [[ -z "${name:-}" ]] && continue
    [[ "${name:0:1}" == "#" ]] && continue
    echo "[$i] $name - ${desc:-}"
    eval "n_$i=\"${name}\""
    i=$((i + 1))
  done <<<"$APP_LIST"
  read -r -p "Select number: " num
  CHOICE="$(eval "echo \"\${n_${num}:-}\"")"
  [[ -z "$CHOICE" ]] && exit 1
fi

SCRIPT_PATH=""
while IFS='|' read -r name path desc tags; do
  [[ -z "${name:-}" ]] && continue
  [[ "${name:0:1}" == "#" ]] && continue
  if [[ "$name" == "$CHOICE" ]]; then
    SCRIPT_PATH="$path"
    break
  fi
done <<<"$APP_LIST"

if [[ -z "$SCRIPT_PATH" ]]; then
  echo "Internal error: selected app not found in list."
  exit 1
fi

bash -c "$(_fetch "${RAW_BASE}/${SCRIPT_PATH}")"

