# 부모 Zone에 환경별 자식 Zone의 NS 레코드를 등록한다.
# 부모 Zone 소유자(Network 관리자)만 적용한다. CI 역할은 부모 Zone을 건드리지 않는다.

data "aws_route53_zone" "parent" {
  name         = var.parent_domain
  private_zone = false
}

resource "aws_route53_record" "subdomain_ns" {
  for_each = var.subdomain_name_servers

  zone_id = data.aws_route53_zone.parent.zone_id
  name    = "${var.delegated_subdomains[each.key]}.${var.parent_domain}"
  type    = "NS"
  ttl     = 300
  records = each.value
}