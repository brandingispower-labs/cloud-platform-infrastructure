region = "ap-northeast-2"

# <부모 도메인>을 이 계정에 있는 부모 Zone 도메인(lab.env의 PARENT_DOMAIN)으로 바꾼다.
# ex) shop.example
parent_domain = "playdevops.click"

delegated_subdomains = {
  dev  = "dev"
  prod = "app"
}

# 환경별 자식 Zone 네임서버 4개. 각 환경 dns/public-zone에서
# terraform output name_servers로 확인한 값으로 바꾼다.
subdomain_name_servers = {
  # ex) "ns-1111.awsdns-11.org", "ns-2222.awsdns-22.co.uk", "ns-333.awsdns-33.com", "ns-444.awsdns-44.net"
  dev = [
    "ns-1481.awsdns-57.org",
    "ns-2025.awsdns-61.co.uk",
    "ns-25.awsdns-03.com",
    "ns-564.awsdns-06.net",
  ]
}