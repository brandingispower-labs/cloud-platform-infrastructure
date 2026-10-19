# GitHub Actions가 OIDC로 받는 CI 역할 두 개와 permissions boundary.
#   gha-<env>-plan  : AWS·State 읽기 + State 잠금 파일 쓰기 (allow_plan_save면 plans/ 쓰기 추가)
#   gha-<env>-apply : 배포 권한(PowerUserAccess + boundary 조건부 IAM) + State 쓰기·지정 버전 읽기

data "aws_caller_identity" "current" {}

locals {
  account_id    = data.aws_caller_identity.current.account_id
  plan_role     = "gha-${var.environment}-plan"
  apply_role    = "gha-${var.environment}-apply"
  boundary_name = "gha-${var.environment}-boundary"
  boundary_arn  = "arn:aws:iam::${local.account_id}:policy/${local.boundary_name}"
  oidc_arn      = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : "arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

# ---------------------------------------------------------------------------
# permissions boundary: CI 역할과 CI가 만드는 역할이 넘을 수 없는 상한선
# ---------------------------------------------------------------------------
resource "aws_iam_policy" "boundary" {
  name = local.boundary_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Sid = "AllowWithinBoundary", Effect = "Allow", Action = "*", Resource = "*" },
      {
        Sid      = "DenyLongLivedCredentials"
        Effect   = "Deny"
        Action   = ["iam:CreateUser", "iam:CreateAccessKey", "iam:CreateLoginProfile"]
        Resource = "*"
      },
      {
        Sid    = "ProtectCiIdentity"
        Effect = "Deny"
        Action = [
          "iam:UpdateAssumeRolePolicy", "iam:DeleteRole", "iam:PutRolePolicy", "iam:DeleteRolePolicy",
          "iam:AttachRolePolicy", "iam:DetachRolePolicy", "iam:PutRolePermissionsBoundary",
          "iam:CreatePolicyVersion", "iam:DeletePolicy", "iam:SetDefaultPolicyVersion",
          "iam:DeleteOpenIDConnectProvider", "iam:UpdateOpenIDConnectProviderThumbprint",
          "iam:AddClientIDToOpenIDConnectProvider", "iam:RemoveClientIDFromOpenIDConnectProvider"
        ]
        Resource = [
          "arn:aws:iam::${local.account_id}:role/gha-*",
          "arn:aws:iam::${local.account_id}:role/OrganizationAccountAccessRole",
          "arn:aws:iam::${local.account_id}:role/aws-reserved/*",
          local.boundary_arn,
          "arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"
        ]
      },
      {
        Sid    = "RoleChangesOnlyWithBoundary"
        Effect = "Deny"
        Action = [
          "iam:CreateRole", "iam:PutRolePermissionsBoundary", "iam:AttachRolePolicy",
          "iam:DetachRolePolicy", "iam:PutRolePolicy", "iam:DeleteRolePolicy"
        ]
        Resource  = "*"
        Condition = { StringNotEquals = { "iam:PermissionsBoundary" = local.boundary_arn } }
      },
      {
        Sid      = "KeepBoundaryOnRoles"
        Effect   = "Deny"
        Action   = "iam:DeleteRolePermissionsBoundary"
        Resource = "*"
      },
      {
        Sid      = "ProtectStateBucket"
        Effect   = "Deny"
        Action   = ["s3:DeleteBucket", "s3:PutBucketPolicy", "s3:DeleteBucketPolicy", "s3:PutBucketVersioning", "s3:PutEncryptionConfiguration", "s3:PutBucketPublicAccessBlock"]
        Resource = var.state_bucket_arn
      },
      {
        Sid      = "DenyAccountAndOrganizationChanges"
        Effect   = "Deny"
        Action   = ["organizations:*", "account:*"]
        Resource = "*"
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# 신뢰 정책: 이 저장소의 GitHub Environment에서 실행된 job만 역할을 받는다.
# sub = <github_subject_prefix>:environment:<Environment 이름>
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "trust" {
  for_each = {
    plan  = "${var.environment}-plan"
    apply = var.environment
  }

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["${var.github_subject_prefix}:environment:${each.value}"]
    }
  }
}

resource "aws_iam_role" "plan" {
  name                 = local.plan_role
  assume_role_policy   = data.aws_iam_policy_document.trust["plan"].json
  permissions_boundary = aws_iam_policy.boundary.arn
  max_session_duration = 3600
}

resource "aws_iam_role" "apply" {
  name                 = local.apply_role
  assume_role_policy   = data.aws_iam_policy_document.trust["apply"].json
  permissions_boundary = aws_iam_policy.boundary.arn
  max_session_duration = 3600
}

# ---------------------------------------------------------------------------
# plan 역할: AWS·State 읽기 + 쓰기는 State 잠금 파일만.
# allow_plan_save = true인 계정(Prod)만 main 전용 prod-plan job이 plans/에 plan을 저장한다.
# ---------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "plan_read_only" {
  role       = aws_iam_role.plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy" "plan_state" {
  name = "terraform-state"
  role = aws_iam_role.plan.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      { Effect = "Allow", Action = "s3:ListBucket", Resource = var.state_bucket_arn },
      { Effect = "Allow", Action = "s3:GetObject", Resource = "${var.state_bucket_arn}/*" },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:DeleteObject"]
        Resource = "${var.state_bucket_arn}/*.tflock"
      }
      ], var.allow_plan_save ? [
      { Sid = "SavePlans", Effect = "Allow", Action = "s3:PutObject", Resource = "${var.state_bucket_arn}/plans/*" }
    ] : [])
  })
}

# ---------------------------------------------------------------------------
# apply 역할: 서비스 배포 권한 + boundary를 붙인 IAM 역할만 만들 수 있는 권한
# ---------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "apply_power_user" {
  role       = aws_iam_role.apply.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role_policy" "apply_iam" {
  name = "iam-with-boundary"
  role = aws_iam_role.apply.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ChangeRolePermissionsOnlyWithBoundary"
        Effect = "Allow"
        Action = [
          "iam:CreateRole", "iam:PutRolePermissionsBoundary", "iam:AttachRolePolicy",
          "iam:DetachRolePolicy", "iam:PutRolePolicy", "iam:DeleteRolePolicy"
        ]
        Resource  = "*"
        Condition = { StringEquals = { "iam:PermissionsBoundary" = local.boundary_arn } }
      },
      {
        Sid    = "ManageWorkloadIam"
        Effect = "Allow"
        Action = [
          "iam:Get*", "iam:List*", "iam:TagRole", "iam:UntagRole", "iam:UpdateRole", "iam:UpdateRoleDescription",
          "iam:UpdateAssumeRolePolicy", "iam:DeleteRole", "iam:PassRole",
          "iam:CreatePolicy", "iam:CreatePolicyVersion", "iam:DeletePolicy", "iam:DeletePolicyVersion",
          "iam:SetDefaultPolicyVersion", "iam:TagPolicy", "iam:UntagPolicy",
          "iam:CreateInstanceProfile", "iam:DeleteInstanceProfile", "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile", "iam:TagInstanceProfile",
          "iam:CreateOpenIDConnectProvider", "iam:DeleteOpenIDConnectProvider", "iam:TagOpenIDConnectProvider",
          "iam:UpdateOpenIDConnectProviderThumbprint", "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "apply_state" {
  name = "terraform-state"
  role = aws_iam_role.apply.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = "s3:ListBucket", Resource = var.state_bucket_arn },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject", "s3:DeleteObject"]
        Resource = "${var.state_bucket_arn}/*"
      }
    ]
  })
}