output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "azs" {
  value = module.vpc.azs
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "EKS 컨트롤 플레인 ENI, RDS, ElastiCache를 놓는 서브넷."
  value       = module.vpc.private_subnets
}

output "intra_subnet_ids" {
  description = "인터넷 경로가 없는 서브넷. SSM 중계 인스턴스용."
  value       = module.vpc.intra_subnets
}

output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}