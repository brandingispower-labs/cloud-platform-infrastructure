variable "account_id" {
  description = "Network 계정 ID. 커밋하지 않고 TF_VAR_account_id로 넣는다."
  type        = string
}

variable "region" {
  type = string
}

variable "parent_domain" {
  description = "Network 계정에 있는 부모 공개 도메인 이름."
  type        = string
}

variable "delegated_subdomains" {
  description = "환경별로 위임할 하위 도메인 이름."
  type        = map(string)
}

variable "subdomain_name_servers" {
  description = "환경별 자식 Zone의 네임서버 4개. 각 환경 dns/public-zone의 name_servers 출력이다."
  type        = map(list(string))
}