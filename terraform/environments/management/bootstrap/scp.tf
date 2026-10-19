# Organizations SCP: 멤버 계정 전체에 걸리는 가드레일.
# CI 역할 권한이 넓어도 아래 세 가지는 어떤 역할로도 할 수 없다(관리자 SSO 역할 예외).

resource "aws_organizations_policy" "region_guard" {
  name        = "deny-unapproved-regions"
  description = "허용 리전 밖에서 리전 서비스를 쓰지 못하게 한다."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyOutsideAllowedRegions"
        Effect = "Deny"
        NotAction = [
          "iam:*", "organizations:*", "account:*", "sts:*", "route53:*", "route53domains:*",
          "cloudfront:*", "waf:*", "wafv2:*", "shield:*", "support:*", "budgets:*", "ce:*",
          "health:*", "trustedadvisor:*", "s3:GetBucketLocation", "s3:ListAllMyBuckets", "acm:*"
        ]
        Resource  = "*"
        Condition = { StringNotEquals = { "aws:RequestedRegion" = var.allowed_regions } }
      },
      {
        # CloudFront 인증서는 us-east-1 ACM에만 만들 수 있어서 ACM만 그 리전을 더 연다.
        Sid       = "AcmOnlyInAllowedAndEdgeRegions"
        Effect    = "Deny"
        Action    = "acm:*"
        Resource  = "*"
        Condition = { StringNotEquals = { "aws:RequestedRegion" = concat(var.allowed_regions, ["us-east-1"]) } }
      }
    ]
  })
}

resource "aws_organizations_policy" "baseline_guard" {
  name        = "protect-ci-and-state"
  description = "CI 역할, OIDC provider, State 버킷 보호와 조직 탈퇴 금지."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ProtectCiIdentity"
        Effect = "Deny"
        Action = [
          "iam:UpdateAssumeRolePolicy", "iam:DeleteRole", "iam:PutRolePolicy", "iam:DeleteRolePolicy",
          "iam:AttachRolePolicy", "iam:DetachRolePolicy", "iam:PutRolePermissionsBoundary",
          "iam:DeleteRolePermissionsBoundary", "iam:CreatePolicyVersion", "iam:DeletePolicy",
          "iam:DeleteOpenIDConnectProvider"
        ]
        Resource = [
          "arn:aws:iam::*:role/gha-*",
          "arn:aws:iam::*:policy/gha-*",
          "arn:aws:iam::*:oidc-provider/token.actions.githubusercontent.com"
        ]
        Condition = { ArnNotLike = { "aws:PrincipalArn" = var.admin_role_patterns } }
      },
      {
        Sid       = "ProtectStateBuckets"
        Effect    = "Deny"
        Action    = ["s3:DeleteBucket", "s3:PutBucketPolicy", "s3:DeleteBucketPolicy", "s3:PutBucketVersioning", "s3:PutLifecycleConfiguration"]
        Resource  = "arn:aws:s3:::cloud-platform-*-tfstate-*"
        Condition = { ArnNotLike = { "aws:PrincipalArn" = var.admin_role_patterns } }
      },
      {
        Sid      = "DenyLeavingOrganization"
        Effect   = "Deny"
        Action   = "organizations:LeaveOrganization"
        Resource = "*"
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "region_guard" {
  for_each = toset(var.guarded_ou_ids)

  policy_id = aws_organizations_policy.region_guard.id
  target_id = each.value
}

resource "aws_organizations_policy_attachment" "baseline_guard" {
  for_each = toset(var.guarded_ou_ids)

  policy_id = aws_organizations_policy.baseline_guard.id
  target_id = each.value
}