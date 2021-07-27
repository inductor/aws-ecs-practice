module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc"
  cidr = "10.100.0.0/16"

  azs             = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  database_subnets    = ["10.100.201.0/24", "10.100.202.0/24", "10.100.203.0/24"]
  private_subnets = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
  public_subnets  = ["10.100.101.0/24", "10.100.102.0/24", "10.100.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "https_443_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/https-443"
  version = "~> 4.0"
  name   = "public-alb-sg"
  vpc_id = module.vpc.default_vpc_id
  egress_rules        = ["all-all"]
}

module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id       = module.vpc.default_vpc_id

  ingress_cidr_blocks = ["10.100.0.0/16"]
}

module "mysql_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/mysql"
  name   = "rds"
  version = "~> 4.0"
  vpc_id       = module.vpc.default_vpc_id

  ingress_cidr_blocks = ["10.100.0.0/16"]
}