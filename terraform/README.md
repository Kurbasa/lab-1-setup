# Лабораторна робота №6 — Terraform + Vercel

## Передумови

- [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.2 (`terraform -v`).
- Акаунт Vercel, токен: **Account Settings → Tokens** (Scope: Full Access для лабораторної інструкції).
- Репозиторій Lab 1 підключено до GitHub; у Vercel має бути можливість імпортувати GitHub-проєкт (інтеграція GitHub–Vercel).

## Налаштування

1. Скопіюй `terraform.tfvars.example` у `terraform.tfvars`.
2. Заповни `vercel_api_token` та `student_id`. За потреби зміни `github_repo` у `variables.tf` або через `-var`.

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

Файл `terraform.tfvars` у `.gitignore` цього каталогу — не коміть токен.
