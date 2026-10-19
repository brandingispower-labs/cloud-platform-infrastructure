variable "account_id" {
  description = "Management 계정 ID. 커밋하지 않고 TF_VAR_account_id로 넣는다."
  type        = string
}

variable "region" {
  type = string
}

variable "allowed_regions" {
  description = "리소스를 만들 수 있는 리전 목록."
  type        = list(string)
}

variable "guarded_ou_ids" {
  description = "SCP를 연결할 OU ID 목록(Infrastructure, Workloads). 커밋하지 않고 TF_VAR_guarded_ou_ids로 넣는다."
  type        = list(string)
}

variable "admin_role_patterns" {
  description = "보호 대상(CI 역할·State 버킷)을 바꿀 수 있는 관리자 SSO 역할 ARN 패턴."
  type        = list(string)
}