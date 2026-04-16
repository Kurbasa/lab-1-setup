variable "vercel_api_token" {
  description = "Vercel API Token for Authentication"
  type        = string
  sensitive   = true
}

variable "student_id" {
  description = "Student ID for custom subdomain: surname, nickname, etc."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository in the form owner/repo (Lab 1 project)"
  type        = string
  default     = "Kurbasa/lab-1-setup"
}

variable "app_root_directory" {
  description = "Subfolder with the Vite app (Lab 1)"
  type        = string
  default     = "my-app"
}
