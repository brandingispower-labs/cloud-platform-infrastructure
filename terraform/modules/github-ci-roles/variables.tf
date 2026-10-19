variable "environment" {
  description = "환경 이름(dev, prod). 역할 이름과 GitHub Environment 이름에 쓴다."
  type        = string
}

variable "github_subject_prefix" {
  description = "실제 토큰에서 확인한 OIDC sub의 저장소 부분(repo:<owner>@<owner ID>/<저장소>@<저장소 ID> 형식)."
  type        = string

  validation {
    condition     = can(regex("^repo:[^:]+$", var.github_subject_prefix))
    error_message = "repo:<owner>/<repo> 부분만 넣습니다. 뒤의 :environment:... 는 모듈이 붙입니다."
  }
}

variable "state_bucket_arn" {
  description = "이 계정의 State 버킷 ARN."
  type        = string
}

variable "allow_plan_save" {
  description = "plan 역할이 State 버킷 plans/에 plan을 저장할 수 있는지. main 전용 prod-plan을 쓰는 Prod만 true."
  type        = bool
  default     = false
}

variable "create_oidc_provider" {
  description = "GitHub OIDC provider를 이 stack에서 만들지 여부. 계정에 이미 있으면 false."
  type        = bool
  default     = true
}