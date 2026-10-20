# 이 환경 전용 공개 자식 Zone. 위임이 끊기지 않게 보존한다.
resource "aws_route53_zone" "public" {
  name    = "${var.subdomain}.${var.parent_domain}"
  comment = "${var.environment} public zone"

  lifecycle {
    prevent_destroy = true
  }
}