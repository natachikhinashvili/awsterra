module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = "my-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets      = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "public_subnet_group" {
  name       = publicsubnet
  subnet_ids = module.vpc.public_subnets
}

resource "aws_db_subnet_group" "private_subnet_group" {
  name       = privatesubnet
  subnet_ids = module.vpc.private_subnets
}
