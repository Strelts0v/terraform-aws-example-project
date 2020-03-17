module "vpc" {
  source               = "../../modules/aws_network"
  env                  = var.env
  vpc_cidr             = "10.111.0.0/16"
  public_subnet_cidrs  = ["10.111.1.0/24", "10.111.2.0/24"]
  private_subnet_cidrs = ["10.111.11.0/24", "10.111.12.0/24"]
}
