resource "vercel_project" "lab_deployment" {
  name      = "lab6-terraform"
  framework = "vite"

  root_directory = var.app_root_directory

  team_id = var.vercel_team

  git_repository = {
    type = "github"
    repo = var.github_repo
  }
}

resource "vercel_project_domain" "custom_domain" {
  project_id = vercel_project.lab_deployment.id
  team_id    = var.vercel_team
  domain     = "lab6-${var.student_id}.vercel.app"
}
