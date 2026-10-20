terraform {
  backend "s3" {
    key          = "network/vpc/terraform.tfstate"
    region       = "ap-northeast-2"
    encrypt      = true
    use_lockfile = true
  }
}