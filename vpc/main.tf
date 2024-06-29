module "natsvpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 3.0.0"

  enable_dns_hostnames = true
  enable_dns_support   = true

  name                 = "natsvpc"
  cidr                 = "10.0.0.0/16"
  azs                  = var.azs
  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets      = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true  # Ensure this parameter is supported by your module version
}

resource "aws_db_subnet_group" "public_subnet_group" {
  name       = var.publicsubnet
  subnet_ids = module.natsvpc.public_subnets
}

resource "aws_db_subnet_group" "private_subnet_group" {
  name       = var.privatesubnet
  subnet_ids = module.natsvpc.private_subnets
}

resource "aws_internet_gateway" "igw" {
  vpc_id = module.natsvpc.vpc_id
}

resource "aws_route_table" "public_rt" {
  count = length(module.natsvpc.public_subnets)
  vpc_id = module.natsvpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  count          = length(module.natsvpc.public_subnets)
  subnet_id      = element(module.natsvpc.public_subnets, count.index)
  route_table_id = aws_route_table.public_rt[count.index].id
}

resource "aws_route_table" "private_rt" {
  count = length(module.natsvpc.private_subnets)
  vpc_id = module.natsvpc.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = module.natsvpc.private_nat_gateway_route_ids[0]  # Use index 0 to access the single element
  }
}

resource "aws_route_table_association" "private_rt_assoc" {
  count          = length(module.natsvpc.private_subnets)
  subnet_id      = element(module.natsvpc.private_subnets, count.index)
  route_table_id = aws_route_table.private_rt[count.index].id
}
