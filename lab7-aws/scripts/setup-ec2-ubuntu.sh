#!/usr/bin/env bash
# Ubuntu 22.04 на EC2: базове середовище для ЛР7 (Node, Git, Nginx, PM2).
set -euo pipefail

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y git nginx ufw

# Node.js 20.x (LTS)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

sudo npm install -g pm2

# Фаєрвол: SSH, HTTP, HTTPS
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable || true

echo "Готово. Далі: клонуй репозиторій, у my-app виконай npm ci && npm run build,"
echo "скопіюй ecosystem.config.cjs і nginx конфіг, pm2 start ecosystem.config.cjs"
