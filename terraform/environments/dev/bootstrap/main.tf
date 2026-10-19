module "state_bucket" {
  source = "../../../modules/state-bucket"

  bucket_name = "cloud-platform-${var.environment}-tfstate-${var.account_id}"
}