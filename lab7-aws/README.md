# Лабораторна робота №7 — AWS (EC2, RDS, S3) + Vite-застосунок з ЛР1

Цей каталог містить **готові шаблони конфігів** і **порядок дій** для звіту. Ресурси AWS (VPC, SG, RDS, EC2, S3, IAM) створюються в **консолі AWS** (або власним Terraform — за бажанням).

## Що тут лежить

| Шлях | Призначення |
|------|-------------|
| `env.example` | Приклад змінних для `.env` на сервері |
| `ecosystem.config.cjs` | PM2: `vite preview` на `0.0.0.0:4173` |
| `nginx/vite-app.conf` | Nginx reverse proxy → Vite |
| `scripts/setup-ec2-ubuntu.sh` | Node 20, Git, Nginx, PM2, UFW |
| `iam/*.json` | Довіра для EC2 і політика доступу до одного бакета |
| `s3/bucket-policy-public-read.json` | Публічне читання об’єктів (заміни ім’я бакета) |
| `s3/cors.json` | CORS для бакета (звузь `AllowedOrigins` у проді) |

У `my-app` додано скрипт `preview:ec2` для прослуховування всіх інтерфейсів (потрібно для Nginx).

---

## Етап 1 — IAM

1. **Не** використовуй root для щоденної роботи.
2. Створи IAM-користувача (наприклад `lab7-nosko`) з **програмним доступом** лише якщо потрібні ключі для **локальних** тестів SDK.
3. Для EC2 краще **IAM Role**: прив’язати роль до інстансу з політикою, обмеженою бакетом — див. `iam/s3-bucket-app-policy.json` (заміни `REPLACE_WITH_BUCKET_NAME`).
4. Trust policy для ролі EC2: `iam/ec2-trust-policy.json`.

---

## Етап 2 — Мережа, RDS, Security Groups

1. У **одному регіоні** (наприклад `eu-central-1`) сплануй VPC: публічна підмережа для EC2, приватна для RDS.
2. **Security Group для RDS** (`rds-sg`): вхід **PostgreSQL 5432** (або MySQL 3306) з джерела = **SG EC2** (не `0.0.0.0/0`).
3. **Security Group для EC2** (`ec2-sg`): вхід **22** (SSH з твоєї IP або тимчасово), **80**, **443**.
4. RDS: шаблон **Free tier**, **Public access = No**, збережи **endpoint**, логін і пароль.

---

## Етап 3 — EC2

1. AMI: **Ubuntu Server 22.04 LTS**, тип **t2.micro**.
2. Key Pair: завантаж `.pem`, з Windows: `ssh -i lab7-key.pem ubuntu@<PUBLIC_IP>`.
3. Підключи **IAM Role** до інстансу (S3 без ключів у `.env`).
4. На сервері виконай (завантаж скрипт з репо або скопіюй вміст):

   ```bash
   chmod +x setup-ec2-ubuntu.sh
   ./setup-ec2-ubuntu.sh
   ```

5. Клонуй репозиторій (той самий, що ЛР1), перейди в `my-app`:

   ```bash
   cd ~/lab-1-setup/my-app
   npm ci
   npm run build
   ```

6. **Шлях** у `ecosystem.config.cjs` (`cwd`) має збігатися з реальним шляхом до `my-app` на сервері.

---

## Етап 4 — S3

1. Створи бакет з **глобально унікальним** ім’ям.
2. Увімкни/налаштуй **Block Public Access** згідно з вимогами лаби: якщо потрібні прямі URL на об’єкти — додай **Bucket policy** з `s3/bucket-policy-public-read.json` (підстав ім’я бакета) і **CORS** з `s3/cors.json`.
3. Перевірка з EC2 (після `aws configure` **не** потрібна, якщо є Role; інакше встанови `awscli`):

   ```bash
   export S3_BUCKET_NAME=your-bucket
   export AWS_REGION=eu-central-1
   chmod +x aws-s3-smoke-test.sh
   ./aws-s3-smoke-test.sh
   ```

---

## Етап 5 — PM2 + Nginx

1. Скопіюй `ecosystem.config.cjs` на сервер, виправ `cwd`.
2. Запуск:

   ```bash
   cd /home/ubuntu/lab-1-setup/my-app
   pm2 start /path/to/ecosystem.config.cjs
   pm2 list
   ```

3. `pm2 startup` + `pm2 save` (див. `scripts/pm2-startup-hint.sh`).
4. Nginx:

   ```bash
   sudo cp vite-app.conf /etc/nginx/sites-available/vite-app
   sudo ln -sf /etc/nginx/sites-available/vite-app /etc/nginx/sites-enabled/default
   sudo nginx -t && sudo systemctl reload nginx
   ```

5. Відкрий у браузері `http://<PUBLIC_IP>/` — має відкритися Vite-збірка.

---

## RDS і `.env`

Якщо підключиш БД до застосунку, додай у `.env` рядок `DATABASE_URL` (формат у `env.example`). Поточний **Vite-фронт** у ЛР1 може працювати без БД; для звіту достатньо **перевірки з’єднання** з RDS (наприклад `psql` з EC2 або клієнт у тій самій VPC).

---

## Що зняти на скріншоти для звіту

- IAM: користувач / роль, політики.
- RDS: параметри, endpoint, SG.
- EC2: інстанс, SG, прив’язана роль.
- S3: бакет, policy, CORS.
- Термінал: `pm2 list`, `nginx -t`, фрагмент логів.
- Браузер: сайт за **публічною IP**.

---

## Висновки

Коротко в звіті: чим EC2 відрізняється від PaaS (Vercel), навіщо RDS у приватній підмережі, чому ключі краще не класти на диск (IAM Role + S3), навіщо Nginx перед Node.
