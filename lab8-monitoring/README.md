# Лабораторна робота №8 — моніторинг, логи, алерти (AWS CloudWatch)

Матеріали для інфраструктури з **ЛР7** (EC2, Ubuntu, Nginx, PM2, застосунок `vite-lab1`).

## Що в каталозі

| Файл | Призначення |
|------|-------------|
| `cloudwatch-agent-config.json` | Повна конфігурація Unified CloudWatch Agent (метрики + логи) |
| `scripts/install-cloudwatch-agent.sh` | Завантаження та встановлення `.deb` |
| `scripts/apply-cw-config.sh` | Застосування JSON-конфігу та запуск агента |
| `docs/metric-filters-hints.md` | Підказки для Metric Filters по логах Nginx |

---

## Етап 1 — IAM

1. **IAM → Roles** → роль, прив’язана до EC2 (наприклад `lab7-ec2-s3-role`), або створи окрему роль лише для лаби.
2. **Add permissions** → прикріпи керовану політику **`CloudWatchAgentServerPolicy`** (дозволяє публікувати метрики та логи в CloudWatch).
3. **EC2 → Instances** → твій інстанс → **Actions → Security → Modify IAM role** — обери роль з цією політикою (до однієї ролі можна додати **кілька** політик: і S3 для ЛР7, і CloudWatch для ЛР8).

---

## Етап 2 — Встановлення агента на EC2

```bash
cd ~
# скопіюй з репозиторію або встав вміст локально
chmod +x lab8-monitoring/scripts/install-cloudwatch-agent.sh
./lab8-monitoring/scripts/install-cloudwatch-agent.sh
```

Або вручну:

```bash
cd /tmp
curl -fSL "https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb" -o amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb
```

---

## Етап 3 — Конфігурація

1. Скопіюй **`cloudwatch-agent-config.json`** на сервер, наприклад:

   `~/lab8-monitoring/cloudwatch-agent-config.json`

2. Перевір шляхи до логів PM2: за замовчуванням для процесу **`vite-lab1`** це:

   - `/home/ubuntu/.pm2/logs/vite-lab1-out.log`
   - `/home/ubuntu/.pm2/logs/vite-lab1-error.log`

   Якщо в **PM2** інша назва застосунку — зміни `file_path` у JSON.

3. Застосуй конфіг:

```bash
chmod +x ~/lab-1-setup/lab8-monitoring/scripts/apply-cw-config.sh   # шлях підлаштуй
sudo ~/lab-1-setup/lab8-monitoring/scripts/apply-cw-config.sh "$(pwd)/lab8-monitoring/cloudwatch-agent-config.json"
```

(або повний шлях до JSON.)

Альтернатива — майстер:

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```

потім злий результат з правками з цього репо.

4. Статус:

```bash
sudo systemctl status amazon-cloudwatch-agent --no-pager
```

---

## Етап 4 — Перевірка в консолі CloudWatch

- **Metrics → All metrics → CWAgent**: `mem_used_percent`, `disk_used_percent`, `swap_used_percent`, CPU тощо.
- **Logs → Log groups**: з’являться `/ec2/lab8/nginx/*` та `/ec2/lab8/pm2/*`.

**Logs Insights** (приклад запиту):

```sql
fields @timestamp, @message
| filter @message like /error/i
| sort @timestamp desc
| limit 50
```

---

## Етап 5 — Metric Filters (4xx / 5xx)

У лог-групі **`/ec2/lab8/nginx/access`** → **Metric filters → Create**.

Патерни залежать від `log_format` — див. `docs/metric-filters-hints.md`.

Створи, наприклад, метрики `Nginx5xxCount` та `Nginx4xxCount`.

---

## Етап 6 — SNS + Alarms

1. **SNS → Topics → Create** — назва на кшталт `InfrastructureAlerts`.
2. **Create subscription** → **Email** → підтверди лист.
3. **CloudWatch → Alarms → Create alarm** — обери метрику (EC2 CPU, CWAgent memory/disk, або метрику з фільтра).

Рекомендовані пороги (за методичкою, підлаштуй під Free Tier):

| Alarm | Джерело метрики | Умова (приклад) |
|-------|------------------|-----------------|
| High-CPU-Warning | EC2 `CPUUtilization` | > 80%, 2×5 хв |
| Low-Memory-Critical | CWAgent `mem_used_percent` | > 90%, 1×5 хв |
| Disk-Full-Alarm | CWAgent `disk_used_percent` | > 85%, 1×5 хв |
| API-5xx-Alert | Custom metric з фільтра | > 5 за 1 хв |

У кожному alarm: **Actions** → **In alarm** → **SNS topic** `InfrastructureAlerts`.

---

## Етап 7 — Дашборд

**CloudWatch → Dashboards → Create** — назва на кшталт `Production-Overview`.

Віджети:

- **Alarm status** / зведення алармів.
- **Line**: CPU (EC2) + `mem_used_percent` (CWAgent).
- За потреби — метрики RDS/S3 з **ЛР7** (окремі віджети).

Період: **3 години**, auto-refresh **10 с** (як у методичці).

---

## Штучне навантаження CPU (доказ алерту)

```bash
sudo apt update && sudo apt install -y stress-ng
stress-ng --cpu 2 --timeout 180
```

Після спрацювання alarm на пошті зроби скрін листа для звіту.

---

## Коментарі до JSON-конфігу (для звіту)

- **Метрики**: `mem_used_percent`, `disk_used_percent`, `swap_used_percent` — видимість насичення RAM/диска; CPU та мережа — для кореляції з навантаженням.
- **Логи**: Nginx access/error — трафік і помилки проксі; PM2 out/error — stdout/stderr Node/Vite.
- **multi_line_start_pattern** (PM2 error): зменшує розбиття stack trace на окремі події; за потреби підлаштуй під реальний формат рядків у `vite-lab1-error.log`.

---

## Висновки (орієнтир для звіту)

- Зависання Node/витік пам’яті проявляється у зростанні **`mem_used_percent`** і помилках у **`/ec2/lab8/pm2/error`**; Nginx access покаже зростання **5xx** при падінні upstream.
- Витрати: платні за обсяг логів (ingestion/storage), кастомні метрики та аларми; у межах Free Tier частина метрик EC2 безкоштовна — орієнтуйся на **AWS Pricing Calculator** і квоти регіону.
- Після ЛР8 інфраструктура ЛР7 придатна до **спостережуваності**; для «проду» додатково потрібні runbooks, on-call і політики зберігання логів.
