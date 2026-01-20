# pve-scripts

Proxmox VE helper scripts (LXC-focused) with an upstream-compatible workflow (same flow, variable names, and output style), but sourced from this repository.

## How to add a new script

1. Copy `ct/_TEMPLATE.sh` → `ct/<app>.sh`.
2. Set `APP="My App"` and your `var_*` defaults (CPU/RAM/Disk/OS/etc).
3. Set `var_install="<nsapp>-install"` to match the installer filename in `install/` (without `.sh`).
4. Copy `install/_TEMPLATE-install.sh` → `install/<nsapp>-install.sh` and implement the install logic.
5. Optional: add an ASCII header at `ct/headers/<nsapp>` (the framework will cache it under `/usr/local/community-scripts/headers/`).
6. Add the app to `misc/app-list.txt` so it shows up in `install.sh`.

Tip: you can override the repository download location (for forks/branches) with `RAW_BASE`, e.g. `RAW_BASE=https://raw.githubusercontent.com/narkomic/pve-scripts/main`.

## Run scripts (upstream-like)

- Menu (recommended): `bash -c "$(curl -fsSL https://raw.githubusercontent.com/narkomic/pve-scripts/main/install.sh)"`
- Direct (example): `bash -c "$(curl -fsSL https://raw.githubusercontent.com/narkomic/pve-scripts/main/ct/profilarr.sh)"`

## Host prerequisites

These scripts run on the Proxmox host (node) and use `pct`/`pvesh` to create and configure containers.

- Required on host: `bash`, `pct`, `pvesh`, `whiptail`, and either `curl` or `wget`.
- Optional host sysctl (kernel keyring limits):
  - The framework checks `/proc/key-users` for UID `100000` (typical unprivileged LXC UID mapping).
  - If usage is near the limit, it stops and suggests creating/editing the host file `/etc/sysctl.d/98-community-scripts.conf` with:
    - `kernel.keys.maxkeys=<value>`
    - `kernel.keys.maxbytes=<value>`
  - Apply changes on the host with `sysctl --system` (or `service procps force-reload`).
  - This is a Proxmox host setting; it is not copied into the container.
  - Optional helper: `host/host-setup.sh`.

## Telemetry (optional)

Diagnostics preference is stored in `/usr/local/community-scripts/diagnostics`. Telemetry is only sent if an API endpoint is configured via `API_BASE_URL` or `PVE_SCRIPTS_API_BASE_URL`.
