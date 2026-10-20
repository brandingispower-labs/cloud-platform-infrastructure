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