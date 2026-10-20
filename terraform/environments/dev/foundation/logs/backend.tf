terraform {
  backend "s3" {
    key          = "foundation/logs/terraform.tfstate"
    region       = "ap-northeast-2"
    encrypt      = true
    use_lockfile = true
  }
}