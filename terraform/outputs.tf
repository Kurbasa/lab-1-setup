output "vercel_project_id" {
  description = "Created Vercel project ID"
  value       = vercel_project.lab_deployment.id
}

output "configured_domain" {
  description = "Domain attached to the project (Lab 6)"
  value       = vercel_project_domain.custom_domain.domain
}
