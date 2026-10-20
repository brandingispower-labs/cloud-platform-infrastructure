module "state_bucket" {
  source = "../../../modules/state-bucket"

  bucket_name = "cloud-platform-network-tfstate-${var.account_id}"
}