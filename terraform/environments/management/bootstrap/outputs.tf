output "state_bucket_name" {
  value = module.state_bucket.bucket_name
}

output "scp_ids" {
  value = {
    region_guard   = aws_organizations_policy.region_guard.id
    baseline_guard = aws_organizations_policy.baseline_guard.id
  }
}