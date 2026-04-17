#!/usr/bin/env bash
# Один раз після першого успішного pm2 start — автозапуск після reboot:
# pm2 startup systemd -u ubuntu --hp /home/ubuntu
# (команда з виводу pm2 виконати з sudo)
# pm2 save

echo "Після налаштування застосунку виконай на сервері:"
echo "  pm2 startup"
echo "  # виконай згенеровану sudo-команду"
echo "  pm2 save"
