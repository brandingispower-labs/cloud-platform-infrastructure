variable "vpc_cidr" {
  description = "VPC 전체 대역. 사설 /16을 쓴다."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr)) && endswith(var.vpc_cidr, "/16")
    error_message = "vpc_cidr는 172.20.0.0/16 같은 /16 대역이어야 합니다."
  }
}

variable "azs" {
  description = "서브넷을 만들 AZ 3개. 순서가 주소 배치를 정하므로 바꾸지 않는다."
  type        = list(string)

  validation {
    condition     = length(distinct(var.azs)) == 3
    error_message = "azs에는 서로 다른 AZ 3개를 넣습니다."
  }
}