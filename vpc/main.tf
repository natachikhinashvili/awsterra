module "natsvpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 3.0.0"

  enable_dns_hostnames = true
  enable_dns_support   = true
  name            = "natsvpc"
  cidr            = "10.0.0.0/16"
  azs             = var.azs
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

resource "aws_db_subnet_group" "public_subnet_group" {
  name       = var.publicsubnet
  subnet_ids = module.natsvpc.public_subnets
}

resource "aws_db_subnet_group" "private_subnet_group" {
  name       = var.privatesubnet
  subnet_ids = module.natsvpc.private_subnets
}