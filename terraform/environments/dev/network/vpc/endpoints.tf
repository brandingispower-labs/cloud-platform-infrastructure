# S3는 Gateway endpoint: 라우팅 테이블에 경로만 추가하고 시간 요금이 없다.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = concat(module.vpc.private_route_table_ids, module.vpc.intra_route_table_ids)

  tags = {
    Name = "${local.name}-s3"
  }
}

# Interface endpoint로 열 서비스.
#   ecr.api, ecr.dkr  이미지 pull     sts   IRSA(vpc-cni) 토큰 교환·역할 인수
#   ssm, ssmmessages, ec2messages     SSM 세션(중계 인스턴스). ec2messages는 구버전 Agent(3.3.40.0 미만) 호환용
locals {
  interface_endpoint_services = ["ecr.api", "ecr.dkr", "sts", "ssm", "ssmmessages", "ec2messages"]
}

# 모든 Interface endpoint가 같이 쓰는 SG. VPC 안에서 오는 HTTPS만 받는다.
resource "aws_security_group" "endpoints" {
  name        = "${local.name}-vpc-endpoints"
  description = "HTTPS from the VPC to interface endpoints"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${local.name}-vpc-endpoints"
  }
}

resource "aws_vpc_security_group_ingress_rule" "endpoints_https" {
  security_group_id = aws_security_group.endpoints.id
  description       = "HTTPS from the VPC"
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

# ENI는 AZ a, b의 EKS 서브넷 두 곳에만 둔다(비용 절감). 다른 AZ도 VPC 안이라 닿는다.
resource "aws_vpc_endpoint" "interface" {
  for_each = toset(local.interface_endpoint_services)

  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for az in slice(var.azs, 0, 2) : aws_subnet.eks[az].id]
  security_group_ids  = [aws_security_group.endpoints.id]

  tags = {
    Name = "${local.name}-${each.key}"
  }
}