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

variable "parent_domain" {
  description = "Network 계정에 있는 부모 도메인 이름."
  type        = string
}

variable "subdomain" {
  description = "이 환경의 하위 도메인 이름. Zone 이름은 <subdomain>.<parent_domain>."
  type        = string
}