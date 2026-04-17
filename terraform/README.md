# Лабораторна робота №6 — Terraform + Vercel

## Передумови

- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.2 (`terraform -v`).
- Акаунт Vercel, токен: **Account Settings → Tokens** (Scope: Full Access для лабораторної інструкції).
- Репозиторій Lab 1 підключено до GitHub; у Vercel має бути можливість імпортувати GitHub-проєкт (інтеграція GitHub–Vercel).

## Налаштування

1. Скопіюй `terraform.tfvars.example` у `terraform.tfvars`.
2. Заповни `vercel_api_token` та `student_id`. За потреби зміни `github_repo` у `variables.tf` або через `-var`.
3. Якщо проєкт у Vercel під **Team**, додай у `terraform.tfvars` рядок `vercel_team = "team_..."` або slug команди (Team → Settings).

## Помилка `forbidden - Not authorized` при `terraform plan`

Terraform **спочатку читає** ресурси з `terraform.tfstate`. Якщо в state збережено `prj_...`, а поточний токен **не має доступу** до цього проєкту (інший акаунт, прострочений токен, проєкт у Team без `vercel_team`), з’явиться **403**.

**Перевірка токена (PowerShell), підстав свій токен:**

```powershell
$t = "ВСТАВ_ТОКЕН_З_VERCEL"
Invoke-RestMethod -Uri "https://api.vercel.com/v9/projects/<PROJECT_ID_з_state_або_Vercel_UI>" -Headers @{ Authorization = "Bearer $t" }
```

Якщо проєкт у **команді**, додай query (підстав свій Team ID з Team Settings):

```powershell
Invoke-RestMethod -Uri "https://api.vercel.com/v9/projects/<PROJECT_ID>?teamId=team_XXXXX" -Headers @{ Authorization = "Bearer $t" }
```

- Відповідь **200** — токен і контекст ок; тоді `terraform plan` має працювати після оновлення `terraform.tfvars`.
- **403** — новий токен з того акаунту, де видно проєкт, і/або коректний `vercel_team`.

**Якщо треба «відв’язати» старий проєкт у state і створити все заново** (наприклад, проєкт належить іншому акаунту й API недоступний):

```bash
terraform state rm vercel_project_domain.custom_domain
terraform state rm vercel_project.lab_deployment
terraform plan
terraform apply
```

Перед цим у Vercel **видали** старий проєкт з таким самим ім’ям, як у `main.tf` (`lab6-terraform`), або зміни `name` в `main.tf`, інакше може бути конфлікт імені.

## Команди

У каталозі `terraform/`:

```bash
terraform init
terraform plan
terraform apply
```

Підтверди `yes` на `apply`.

## URL для звіту

- Основний домен проєкту Vercel + домен з `vercel_project_domain` (наприклад `lab6-<student_id>.vercel.app`), якщо він успішно прив’язаний.

## Дрейф конфігурації (для звіту)

1. Після успішного `apply` відкрий Vercel Dashboard і **вручну зміни** щось, що описано в Terraform (наприклад перейменуй проєкт або зміни домен).
2. Знову виконай `terraform plan`.
3. У звіті опиши: Terraform покаже **розбіжність** між кодом і реальністю та запропонує **кроки для повернення** до декларованого стану (або оновлення state після `terraform refresh` / імпорту — залежно від змін).

## Примітка про `terraform.tfvars`

Файл `terraform.tfvars` у `.gitignore` цього каталогу — не коміть токен. Орієнтир по формату (`vcp_...`) зручно тримати **лише локально** в `terraform.tfvars`; у `terraform.tfvars.example` залишай плейсхолдер `your-vercel-api-token`, інакше GitHub може заблокувати push через сканування секретів.
