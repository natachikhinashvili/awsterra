terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
  backend "s3" {
    bucket = "natsbackend"
    key    = "backend.tfstate"
    region = "eu-central-1"
  }
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "database-creds"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

module "ecr" {
  source         = "./ecr"
  repositoryname = var.repositoryname
  region         = var.region
}

module "vpc" {
  source        = "./vpc"
  vpcname       = var.vpcname
  publicsubnet  = var.publicsubnet
  privatesubnet = var.privatesubnet
  azs           = var.azs
}

module "security_group" {
  source            = "./security_group"
  security_group_id = module.security_group.security_group_id
  vpc_id            = module.vpc.vpc_id
}


module "ecs" {
  source                  = "./ecs"
  security_group_ids      = module.security_group.security_group_id
  vpc_id                  = module.vpc.vpc_id
  repository_url          = module.ecr.repository_url
  privatesubnet           = module.vpc.public_subnets
  subnet                  = module.vpc.public_subnets
  aws_lb_target_group_arn = module.load_balancer.aws_lb_target_group_arn
  container_name = var.container_name
  service_name = var.service_name
  capacityprovidername = var.capacityprovidername
}

module "rds" {
  source        = "./rds"
  depends_on    = [module.vpc]
  subnetgroup   = var.publicsubnet
  securitygroup = [module.security_group.rds_security_group_id]
  username      = local.db_creds.username
  password      = local.db_creds.password
  db_name       = var.db_name
}
module "load_balancer" {
  source            = "./alb"
  security_group_id = module.security_group.alb_security_group
  vpc_id            = module.vpc.vpc_id
  subnets           = module.vpc.public_subnet_group
}