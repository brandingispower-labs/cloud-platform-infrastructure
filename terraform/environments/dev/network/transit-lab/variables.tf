variable "account_id" {
  description = "AWS 계정 ID. CI는 TF_VAR_account_id로 넣는다."
  type        = string
}

variable "permissions_boundary_arn" {
  description = "CI가 만드는 IAM 역할에 붙일 boundary. CI는 TF_VAR_permissions_boundary_arn으로 넣는다."
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

variable "vpc_cidrs" {
  description = "실습 VPC 두 개의 CIDR. 서로 겹치면 안 된다."
  type        = map(string)
}

variable "az" {
  description = "실습 서브넷을 둘 가용 영역 하나."
  type        = string
}