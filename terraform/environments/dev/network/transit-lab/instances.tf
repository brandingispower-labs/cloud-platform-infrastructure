# VPC마다 테스트 EC2 한 대. 공인 IP 없이 SSM으로 접속하고, 8080 포트로 간단한 웹 응답을 낸다.

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_iam_role" "test" {
  name                 = "${local.name}-test"
  permissions_boundary = var.permissions_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "test_ssm" {
  role       = aws_iam_role.test.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "test" {
  name = "${local.name}-test"
  role = aws_iam_role.test.name
}

# 상대 VPC에서 오는 ping(ICMP)과 8080만 받는다.
resource "aws_security_group" "test" {
  for_each = var.vpc_cidrs

  name   = "${local.name}-${each.key}-test"
  vpc_id = aws_vpc.lab[each.key].id

  ingress {
    description = "ping from the other VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [for k, cidr in var.vpc_cidrs : cidr if k != each.key]
  }

  ingress {
    description = "web from the other VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [for k, cidr in var.vpc_cidrs : cidr if k != each.key]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "test" {
  for_each = var.vpc_cidrs

  ami                         = data.aws_ssm_parameter.al2023.insecure_value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private[each.key].id
  vpc_security_group_ids      = [aws_security_group.test[each.key].id]
  iam_instance_profile        = aws_iam_instance_profile.test.name
  associate_public_ip_address = false

  metadata_options {
    http_tokens = "required"
  }

  user_data = <<-EOT
    #!/bin/bash
    mkdir -p /srv/web && echo "hello from ${each.key}" > /srv/web/index.html
    systemd-run --unit=lab-web --working-directory=/srv/web python3 -m http.server 8080
  EOT

  tags = { Name = "${local.name}-${each.key}" }

  depends_on = [aws_vpc_endpoint.ssm]

  lifecycle {
    ignore_changes = [ami]
  }
}