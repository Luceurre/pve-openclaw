#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: pglandon
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://openclaw.ai | Github: https://github.com/openclaw/openclaw

APP="OpenClaw"
var_tags="${var_tags:-ai;assistant}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if ! command -v openclaw &>/dev/null; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  RELEASE=$(npm view openclaw version 2>/dev/null)
  if [[ -z "${RELEASE}" ]]; then
    msg_error "Could not fetch latest ${APP} version from npm!"
    exit
  fi

  if [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt 2>/dev/null)" ]]; then
    msg_info "Stopping Service"
    systemctl stop openclaw
    msg_ok "Stopped Service"

    msg_info "Updating ${APP} to v${RELEASE}"
    $STD npm update -g openclaw
    msg_ok "Updated ${APP} to v${RELEASE}"

    msg_info "Starting Service"
    systemctl start openclaw
    msg_ok "Started Service"

    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Update Successful"
  else
    msg_ok "No update required. ${APP} is already at v${RELEASE}"
  fi
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:18789${CL}"
