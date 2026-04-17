#!/usr/bin/env bash
# Застосування конфігурації агента (шлях до JSON передай першим аргументом).
set -euo pipefail
CONFIG="${1:?Вкажи шлях до cloudwatch-agent-config.json}"

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c "file:${CONFIG}"

sudo systemctl status amazon-cloudwatch-agent --no-pager || true
echo "Перевір CloudWatch: Metrics → CWAgent, Logs → log groups з префіксом /ec2/lab8/"
