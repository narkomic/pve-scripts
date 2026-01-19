#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/narkomic/pve-scripts/main/misc/build.func)

APP="Profilarr"
var_tags="${var_tags:-arr;radarr;sonarr}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-10}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"

# Docker i LXC er mest gnidningsfrit i privileged
var_unprivileged="${var_unprivileged:-0}"

# Matcher filnavnet: install/profilarr-install.sh (uden .sh)
var_install="${var_install:-profilarr-install}"

header_info "$APP"
variables
color
catch_errors

start
build_container
description
install_script

msg_ok "Completed Successfully!"
echo -e "${INFO}${YW} Access URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:6868${CL}\n"
