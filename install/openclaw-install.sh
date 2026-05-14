#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: pglandon
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://openclaw.ai | Github: https://github.com/openclaw/openclaw

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  git \
  python3 \
  openssl \
  procps
msg_ok "Installed Dependencies"

NODE_VERSION="24" setup_nodejs

msg_info "Installing OpenClaw"
$STD npm install -g openclaw@latest
RELEASE=$(npm view openclaw version)
echo "${RELEASE}" >/opt/OpenClaw_version.txt
msg_ok "Installed OpenClaw v${RELEASE}"

msg_info "Configuring OpenClaw"
mkdir -p /root/.openclaw/workspace
cat <<EOF >/root/.openclaw/openclaw.json
{
  "agent": {
    "model": "openai/gpt-4o"
  }
}
EOF
msg_ok "Configured OpenClaw"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/openclaw.service
[Unit]
Description=OpenClaw Gateway
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/openclaw gateway --bind lan --port 18789 --allow-unconfigured
Restart=on-failure
RestartSec=10
Environment=HOME=/root
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now openclaw
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
