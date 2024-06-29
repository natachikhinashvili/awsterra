output "vpc_id" {
  value = module.natsvpc.vpc_id
}

output "public_subnets" {
  value = module.natsvpc.public_subnets
}

output "private_subnets" {
  value = module.natsvpc.private_subnets
}


output "public_subnet_group" {
  value = module.natsvpc.public_subnets
}