module "state_bucket" {
  source = "../../../modules/state-bucket"

  bucket_name = "cloud-platform-management-tfstate-${var.account_id}"
}