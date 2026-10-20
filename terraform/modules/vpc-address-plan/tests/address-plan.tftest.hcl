# AWS 없이 주소 계산만 확인한다. 이 모듈에는 리소스가 없어서 plan만으로 충분하다.
variables {
  vpc_cidr = "172.20.0.0/16"
  azs      = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
}

run "dev_address_plan" {
  command = plan

  assert {
    condition     = output.public_subnets == ["172.20.0.0/22", "172.20.4.0/22", "172.20.8.0/22"]
    error_message = "public 서브넷 주소가 계획과 다릅니다."
  }

  assert {
    condition     = output.intra_subnets == ["172.20.12.0/28", "172.20.12.16/28", "172.20.12.32/28"]
    error_message = "intra 서브넷 주소가 계획과 다릅니다."
  }

  assert {
    condition     = output.private_subnets == ["172.20.32.0/19", "172.20.64.0/19", "172.20.96.0/19"]
    error_message = "private 서브넷 주소가 계획과 다릅니다."
  }

  assert {
    condition     = output.eks_subnets == ["172.20.128.0/19", "172.20.160.0/19", "172.20.192.0/19"]
    error_message = "eks 서브넷 주소가 계획과 다릅니다."
  }
}

run "rejects_non_16_cidr" {
  command = plan

  variables {
    vpc_cidr = "172.20.0.0/20"
  }

  expect_failures = [var.vpc_cidr]
}