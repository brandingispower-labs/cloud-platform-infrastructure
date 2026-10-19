module "state_bucket" {
  source = "../../../modules/state-bucket"

  bucket_name = "cloud-platform-${var.environment}-tfstate-${var.account_id}"
}

module "github_ci_roles" {
  source = "../../../modules/github-ci-roles"

  environment           = var.environment
  github_subject_prefix = var.github_subject_prefix
  state_bucket_arn      = module.state_bucket.bucket_arn
}