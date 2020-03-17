module "db_security_group" {
  source = "../../modules/aws_security_group"
  name   = "DB ${var.env} ${var.project} Security Group"
  vpc_id = module.vpc.vpc_id

  allowed_ports = ["3306", "80", "443", "22"]

  tags = merge(
    var.common_tags,
    { Name = "DB ${var.env} ${var.project} Security Group" }
  )
}

// Generate Password
resource "random_string" "rds_password" {
  length           = 15
  special          = true
  override_special = "!#$&"

  keepers = {
    default_kepeer = "${var.project}-${var.env}"
  }
}

// Store Password in SSM Parameter Store
resource "aws_ssm_parameter" "rds_password" {
  name        = "/${var.project}/${var.env}/mysql"
  description = "Master Password for RDS"
  type        = "SecureString"
  value       = random_string.rds_password.result
}

// Get Password from SSM Parameter Store
data "aws_ssm_parameter" "my_rds_password" {
  name       = "/${var.project}/${var.env}/mysql"
  depends_on = [aws_ssm_parameter.rds_password]
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group_${var.env_lower}"
  subnet_ids = module.vpc.private_subnet_ids

  tags = merge(
    var.common_tags,
    {
      "Name" = "${var.env} DB Subnet Group"
    },
  )
}

module "db" {
  source = "../../modules/aws_rds"

  identifier = "example-project-db"

  engine            = "mysql"
  engine_version    = "5.7.26"
  instance_class    = "db.t2.micro"
  allocated_storage = 5
  storage_encrypted = false

  name     = "exampledb"
  username = "user"
  password = data.aws_ssm_parameter.my_rds_password.value
  port     = "3306"

  vpc_security_group_ids = [module.db_security_group.security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  maintenance_window     = "Mon:00:00-Mon:03:00"
  backup_window          = "03:00-06:00"
  multi_az               = false

  # disable backups to create DB faster
  backup_retention_period = 0

  enabled_cloudwatch_logs_exports = ["audit", "general"]
  final_snapshot_identifier       = "example-project-db"
  deletion_protection             = false

  tags = merge(
    var.common_tags,
    {
      "Name" = "${var.project} ${var.env} RDS"
    },
  )
}
