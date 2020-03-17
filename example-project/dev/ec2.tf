module "web_security_group" {
  source = "../../modules/aws_security_group"
  name   = "Web ${var.env} ${var.project} Security Group"
  vpc_id = module.vpc.vpc_id

  tags = merge(
    var.common_tags,
    { Name = "Web ${var.env} ${var.project} Security Group" }
  )
}

module "autoscaling_group" {
  source              = "../../modules/aws_autoscaling_group"
  vpc_zone_identifier = module.vpc.public_subnet_ids
  security_groups     = [module.web_security_group.security_group_id]
  elb_name            = "${var.env}-${var.project}-ELB"
  vpc_subnets         = module.vpc.public_subnet_ids

  tags = merge(
    var.common_tags,
    { Name = "${var.env} ${var.project} Autoscaling Group" }
  )
}
