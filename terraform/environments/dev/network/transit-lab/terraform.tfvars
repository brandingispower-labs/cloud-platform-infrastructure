region      = "ap-northeast-2"
environment = "dev"
name_prefix = "commerce"
az          = "ap-northeast-2a"

vpc_cidrs = {
  app    = "10.110.0.0/16"
  shared = "10.120.0.0/16"
}