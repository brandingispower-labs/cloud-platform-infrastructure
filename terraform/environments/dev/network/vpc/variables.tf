variable "account_id" {
  description = "AWS 계정 ID. CI는 TF_VAR_account_id로 넣는다."
  type        = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "vpc_cidr" {
  description = "VPC 전체 대역(/16). 연결할 다른 네트워크와 겹치지 않게 정한다."
  type        = string
}

variable "azs" {
  description = "AZ 3개. 순서가 서브넷 주소를 정하므로 운영 중에는 바꾸지 않는다."
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "true면 NAT Gateway 1개를 모든 AZ가 같이 쓴다(Dev 비용 절감)."
  type        = bool
}

variable "state_bucket" {
  description = "다른 stack의 State를 읽을 버킷. CI는 TF_VAR_state_bucket으로 넣는다."
  type        = string
}