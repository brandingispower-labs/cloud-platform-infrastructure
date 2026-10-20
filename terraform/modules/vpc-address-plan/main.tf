# /16을 /19 블록 8개로 나눠 용도별로 배정한다.
#   블록 0     public /22 x3, intra /28 x3 (작게 쪼개 함께 담음)
#   블록 1~3   private /19 (AZ a, b, c)
#   블록 4~6   eks /19     (AZ a, b, c)
#   블록 7     예비
locals {
  public_subnets  = [for i, az in var.azs : cidrsubnet(var.vpc_cidr, 6, i)]
  intra_subnets   = [for i, az in var.azs : cidrsubnet(var.vpc_cidr, 12, 192 + i)]
  private_subnets = [for i, az in var.azs : cidrsubnet(var.vpc_cidr, 3, 1 + i)]
  eks_subnets     = [for i, az in var.azs : cidrsubnet(var.vpc_cidr, 3, 4 + i)]
}