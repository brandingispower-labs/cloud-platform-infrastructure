region          = "ap-northeast-2"
allowed_regions = ["ap-northeast-2"]
admin_role_patterns = [
  "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*AWSReservedSSO_InfrastructureProvisioner_*",
  "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*AWSReservedSSO_OrganizationAdministrator_*",
]