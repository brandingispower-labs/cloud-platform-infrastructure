# EKS 노드와 Pod 전용 서브넷. 주소는 address_plan의 /19 블록 4~6.
locals {
  eks_subnets = zipmap(var.azs, module.address_plan.eks_subnets)
}

resource "aws_subnet" "eks" {
  for_each = local.eks_subnets

  vpc_id                  = module.vpc.vpc_id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = false

  # 내부 LB 태그는 private 서브넷에만 둔다(main.tf). 여기에는 붙이지 않는다.
  tags = {
    Name = "${local.name}-eks-${each.key}"
  }
}

# 같은 AZ의 private 라우팅 테이블(NAT 경로)을 같이 쓴다.
# NAT가 1개면 테이블도 1개라 element()가 첫 번째 테이블로 돌아간다.
resource "aws_route_table_association" "eks" {
  for_each = local.eks_subnets

  subnet_id      = aws_subnet.eks[each.key].id
  route_table_id = element(module.vpc.private_route_table_ids, index(var.azs, each.key))
}