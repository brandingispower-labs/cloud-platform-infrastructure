region      = "ap-northeast-2"
environment = "dev"

# <부모 도메인>을 Network 계정에 있는 부모 도메인(lab.env의 PARENT_DOMAIN)으로 바꾼다.
# ex) shop.example
parent_domain = "playdevops.click"

# subdomain: 이 환경의 하위 도메인. Zone 이름은 dev.<부모 도메인> 형태가 된다.
subdomain = "dev"