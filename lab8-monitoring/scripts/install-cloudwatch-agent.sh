#!/usr/bin/env bash
# Ubuntu 22.04/24.04 amd64 — Unified CloudWatch Agent (ЛР8).
# Перед запуском: IAM роль EC2 має містити CloudWatchAgentServerPolicy.
set -euo pipefail

ARCH="$(uname -m)"
if [[ "$ARCH" != "x86_64" ]]; then
  echo "Скрипт очікує amd64 (x86_64). Для ARM використай відповідний .deb з документації AWS."
  exit 1
fi

cd /tmp
curl -fSL "https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb" -o amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
echo "Встановлено. Далі скопіюй cloudwatch-agent-config.json і виконай apply-cw-config.sh"
