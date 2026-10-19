# 처음 apply는 이 파일 없이(로컬 State) 실행하고, State 버킷이 생긴 뒤 추가해 이관한다.
# bucket 값은 커밋하지 않는 환경 backend.hcl로 넣는다: terraform init -backend-config=../backend.hcl
terraform {
  backend "s3" {
    key          = "bootstrap/terraform.tfstate"
    region       = "ap-northeast-2"
    encrypt      = true
    use_lockfile = true
  }
}