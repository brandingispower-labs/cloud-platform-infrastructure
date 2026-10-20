output "zone_id" {
  value = aws_route53_zone.public.zone_id
}

output "zone_name" {
  value = aws_route53_zone.public.name
}

output "name_servers" {
  value = aws_route53_zone.public.name_servers
}