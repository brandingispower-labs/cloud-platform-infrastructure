variable "account_id" {
  description = "이 stack을 적용할 AWS 계정 ID. 커밋하지 않고 TF_VAR_account_id로 넣는다."
  type        = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}