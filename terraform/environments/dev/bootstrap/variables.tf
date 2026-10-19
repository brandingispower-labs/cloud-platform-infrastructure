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

variable "github_subject_prefix" {
  description = "CI 역할을 받을 저장소의 OIDC sub 앞부분(repo:<owner>@<id>/<repo>@<id>). 실제 토큰으로 확인한 값."
  type        = string
}