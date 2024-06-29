terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 2.7.0"
        }
    }
}

resource "aws_s3_bucket" "nats_backend" {
    bucket = var.bucket_name
    acl    = "private"
}


module "ecr" {
  source = "./ecr"
  repositoryname="natsrepo"
  region = "eu-central-1"
}
module "vpc" {
  source = "./vpc"
  vpcname = "natsvpc"
  publicsubnet = "db-subnet-group-public"
  privatesubnet = "db-subnet-group-private"
  azs =  ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}
module "security_group" {
  source = "./security_group"
  security_group_id = module.security_group.security_group_id
  vpc_id =var.vpc_id
}


module "ecs" {
    source             = "./ecs"
    security_group_ids = module.security_group.security_group_id
    subnet = module.vpc.public_subnets
}

module "rds" {
    source             = "./rds"
    subnetgroup = module.vpc.public_subnet_group[0]
    securitygroup = [module.security_group.rds_security_group_name]
    
}
module "load_balancer" {
    source             = "./alb"
    security_group_id = module.security_group.security_group_id
    vpc_id = var.vpc_id
}