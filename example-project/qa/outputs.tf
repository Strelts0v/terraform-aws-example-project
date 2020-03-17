output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "web_loadbalancer_url" {
  value = module.autoscaling_group.web_loadbalancer_url
}

output "rds_password" {
  value = data.aws_ssm_parameter.my_rds_password.value
}
