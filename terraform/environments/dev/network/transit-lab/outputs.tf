output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.lab.id
}

output "tgw_route_table_id" {
  description = "기본 TGW 라우팅 테이블. 두 VPC CIDR이 전파되는 곳."
  value       = aws_ec2_transit_gateway.lab.association_default_route_table_id
}

output "instance_ids" {
  value = { for k, i in aws_instance.test : k => i.id }
}

output "private_ips" {
  value = { for k, i in aws_instance.test : k => i.private_ip }
}

output "shared_ip" {
  description = "app EC2에서 ping·curl을 보낼 대상 주소."
  value       = aws_instance.test["shared"].private_ip
}

output "route_table_ids" {
  value = { for k, rt in aws_route_table.private : k => rt.id }
}