# Transit Gateway 하나에 두 VPC를 붙이고, 양쪽 VPC 라우팅 테이블에 상대 CIDR 경로를 넣는다.

resource "aws_ec2_transit_gateway" "lab" {
  description                     = "${local.name} lab"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"

  tags = { Name = local.name }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "lab" {
  for_each = var.vpc_cidrs

  transit_gateway_id = aws_ec2_transit_gateway.lab.id
  vpc_id             = aws_vpc.lab[each.key].id
  subnet_ids         = [aws_subnet.private[each.key].id]

  tags = { Name = "${local.name}-${each.key}" }
}

# app -> shared 로 가는 길
resource "aws_route" "app_to_shared" {
  route_table_id         = aws_route_table.private["app"].id
  destination_cidr_block = var.vpc_cidrs["shared"]
  transit_gateway_id     = aws_ec2_transit_gateway.lab.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.lab]
}

# shared -> app 으로 돌아오는 길
resource "aws_route" "shared_to_app" {
  route_table_id         = aws_route_table.private["shared"].id
  destination_cidr_block = var.vpc_cidrs["app"]
  transit_gateway_id     = aws_ec2_transit_gateway.lab.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.lab]
}