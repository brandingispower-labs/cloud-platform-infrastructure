output "state_bucket_name" {
  value = module.state_bucket.bucket_name
}

output "plan_role_arn" {
  value = module.github_ci_roles.plan_role_arn
}

output "apply_role_arn" {
  value = module.github_ci_roles.apply_role_arn
}

output "permissions_boundary_arn" {
  value = module.github_ci_roles.permissions_boundary_arn
}