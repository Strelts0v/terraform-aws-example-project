provider "aws" {
  version = "~> 2.52"
  region  = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket  = "terraform-example-project-state"
    key     = "prod/terraform.tfstate"
    encrypt = "true"
    region  = "eu-central-1"
  }
}

data "aws_availability_zones" "az" {}

module "vpc" {
  source               = "../../modules/aws_network"
  env                  = var.env
  vpc_cidr             = "10.200.0.0/16"
  public_subnet_cidrs  = ["10.200.1.0/24", "10.200.2.0/24", "10.200.3.0/24"]
  private_subnet_cidrs = ["10.200.11.0/24", "10.200.12.0/24"]
}

module "security_group" {
  source = "../../modules/aws_security_group"
  name   = "${var.env} ${var.project} Security Group"
  vpc_id = module.vpc.vpc_id

  tags = merge(
    var.common_tags,
    { Name = "${var.env} ${var.project} Security Group" }
  )
}

module "autoscaling_group" {
  source              = "../../modules/aws_autoscaling_group"
  vpc_zone_identifier = module.vpc.public_subnet_ids
  security_groups     = [module.security_group.security_group_id]
  elb_name            = "${var.env}-${var.project}-ELB"
  vpc_subnets         = module.vpc.public_subnet_ids

  tags = merge(
    var.common_tags,
    { Name = "${var.env} ${var.project} Autoscaling Group" }
  )
}
