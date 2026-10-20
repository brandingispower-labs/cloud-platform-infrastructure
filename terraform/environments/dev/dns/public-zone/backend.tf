terraform {
  backend "s3" {
    key          = "dns/public-zone/terraform.tfstate"
    region       = "ap-northeast-2"
    encrypt      = true
    use_lockfile = true
  }
}