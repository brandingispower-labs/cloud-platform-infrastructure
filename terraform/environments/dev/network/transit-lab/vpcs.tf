# 실습용 VPC 두 개(app, shared). 인터넷 경로 없이 private 서브넷 하나씩만 둔다.

locals {
  name = "${var.name_prefix}-${var.environment}-transit"
}

resource "aws_vpc" "lab" {
  for_each = var.vpc_cidrs

  cidr_block           = each.value
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${local.name}-${each.key}" }
}

resource "aws_subnet" "private" {
  for_each = var.vpc_cidrs

  vpc_id            = aws_vpc.lab[each.key].id
  cidr_block        = cidrsubnet(each.value, 8, 1)
  availability_zone = var.az

  tags = { Name = "${local.name}-${each.key}-private" }
}

resource "aws_route_table" "private" {
  for_each = var.vpc_cidrs

  vpc_id = aws_vpc.lab[each.key].id

  tags = { Name = "${local.name}-${each.key}-private" }
}

resource "aws_route_table_association" "private" {
  for_each = var.vpc_cidrs

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

# SSM으로 접속하는 곳은 app EC2뿐이라 SSM endpoint 세 개는 app VPC에만 둔다.
# shared EC2는 ping과 8080 응답만 하면 되니 endpoint가 필요 없다.
resource "aws_security_group" "endpoint" {
  name   = "${local.name}-app-endpoint"
  vpc_id = aws_vpc.lab["app"].id

  ingress {
    description = "HTTPS from the app VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidrs["app"]]
  }
}

resource "aws_vpc_endpoint" "ssm" {
  for_each = toset(["ssm", "ssmmessages", "ec2messages"])

  vpc_id              = aws_vpc.lab["app"].id
  service_name        = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.private["app"].id]
  security_group_ids  = [aws_security_group.endpoint.id]
  private_dns_enabled = true

  tags = { Name = "${local.name}-app-${each.key}" }
}