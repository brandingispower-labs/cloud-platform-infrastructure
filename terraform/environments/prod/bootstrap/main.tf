module "state_bucket" {
  source = "../../../modules/state-bucket"

  bucket_name = "cloud-platform-${var.environment}-tfstate-${var.account_id}"
}

module "github_ci_roles" {
  source = "../../../modules/github-ci-roles"

  environment           = var.environment
  github_subject_prefix = var.github_subject_prefix
  state_bucket_arn      = module.state_bucket.bucket_arn

  # Prod plan은 main 전용 prod-plan job이 plans/에 저장하고, 승인 뒤 그 버전만 적용한다.
  allow_plan_save = true
}