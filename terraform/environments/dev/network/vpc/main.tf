locals {
  name = "${var.name_prefix}-${var.environment}"
}

# 서브넷 주소는 계산 전용 모듈이 정한다.
module "address_plan" {
  source = "../../../../modules/vpc-address-plan"

  vpc_cidr = var.vpc_cidr
  azs      = var.azs
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.2"

  name = "${local.name}-vpc"
  cidr = var.vpc_cidr
  azs  = var.azs

  public_subnets  = module.address_plan.public_subnets
  private_subnets = module.address_plan.private_subnets
  intra_subnets   = module.address_plan.intra_subnets

  # Interface endpoint의 private DNS가 동작하려면 둘 다 켜야 한다.
  enable_dns_support   = true
  enable_dns_hostnames = true

  # private 서브넷의 인터넷 출구. Dev는 NAT 1개, Prod는 AZ마다 1개.
  enable_nat_gateway     = true
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = !var.single_nat_gateway

  map_public_ip_on_launch = false

  # 기본 SG는 규칙을 비워 아무도 쓰지 못하게 한다.
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  # AWS Load Balancer Controller가 LB를 놓을 서브넷을 찾는 태그.
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}