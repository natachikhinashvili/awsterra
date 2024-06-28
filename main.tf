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

#module "ecs" {
#    source             = "./ecs"
#    security_group_id = module.security_group.security_group_id
#    vpc_id = var.vpc_id
#    aws_lb_target_group_arn = module.load_balancer.aws_lb_target_group_arn
#}
#
#module "load_balancer" {
#    source             = "./alb"
#    security_group_id = module.security_group.security_group_id
#    vpc_id = var.vpc_id
#}