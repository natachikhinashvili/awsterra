module "secretsmanager" {
  source        = "./secretsmanager"
}

module "ecr" {
  source         = "./ecr"
  region         = var.region
}

module "vpc" {
  source        = "./vpc"
  publicsubnet  = var.publicsubnet
  privatesubnet = var.privatesubnet
  azs           = var.azs
}

module "security_group" {
  source            = "./security_group"
  security_group_id = module.security_group.security_group_id
  vpc_id            = module.vpc.vpc_id
}

module "load_balancer" {
  source            = "./alb"
  security_group_id = module.security_group.alb_security_group
  vpc_id            = module.vpc.vpc_id
  subnets           = module.vpc.public_subnet_group
}

module "ecs" {
  source                  = "./ecs"
  security_group_ids      = module.security_group.security_group_id
  vpc_id                  = module.vpc.vpc_id
  repository_url          = module.ecr.repository_url
  privatesubnet           = module.vpc.public_subnets
  subnet                  = module.vpc.public_subnets
  aws_lb_target_group_arn = module.load_balancer.aws_lb_target_group_arn
}

module "rds" {
  source        = "./rds"
  depends_on    = [module.vpc]
  subnetgroup   = var.publicsubnet
  securitygroup = [module.security_group.rds_security_group_id]
  username      = "admin"
  password      = local.db_creds.password
}