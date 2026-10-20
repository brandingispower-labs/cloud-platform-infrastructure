# 로그 버킷은 수명이 다른 foundation/logs stack이 가지고 있다. 그 출력을 읽는다.
data "terraform_remote_state" "logs" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = "foundation/logs/terraform.tfstate"
    region = var.region
  }
}

# VPC 안 ENI의 허용·거부 IP 트래픽(Amazon DNS·metadata 등 일부 제외)을 S3 flow/ 아래에 남긴다.
resource "aws_flow_log" "vpc" {
  vpc_id                   = module.vpc.vpc_id
  traffic_type             = "ALL"
  max_aggregation_interval = 60
  log_destination_type     = "s3"
  log_destination          = "${data.terraform_remote_state.logs.outputs.log_bucket_arn}/flow/"

  tags = {
    Name = "${local.name}-flow-log"
  }
}