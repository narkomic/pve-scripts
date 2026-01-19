#!/usr/bin/env bash
# Source build framework (same style as community-scripts)
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

header_info "$APP"
variables
color
catch_errors

function install_app() {
  msg_info "Installing ${APP}"
  bash <(curl -fsSL https://raw.githubusercontent.com/narkomic/pve-scripts/main/install/profilarr-install.sh)
  msg_ok "Installed ${APP}"
}

start
build_container
description
install_app

msg_ok "Completed Successfully!\n"
echo -e "${INFO}${YW} Access URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:6868${CL}\n"
