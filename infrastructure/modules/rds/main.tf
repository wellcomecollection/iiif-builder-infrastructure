resource "aws_db_subnet_group" "db" {
  name       = "${local.full_name}-db"
  subnet_ids = var.db_subnets
  tags       = local.common_tags
}

resource "aws_security_group" "postgres_access" {
  description = "Access to Postgres"
  vpc_id      = var.vpc_id
  name        = "${local.full_name}-postgres-access"

  ingress {
    protocol    = "tcp"
    from_port   = "5432"
    to_port     = "5432"
    cidr_blocks = var.db_ingress_cidrs
  }
  tags = local.common_tags
}

data "aws_ssm_parameter" "database_password" {
  name = var.db_password_ssm_key
}

data "aws_ssm_parameter" "database_username" {
  name = var.db_username_ssm_key
}

resource "aws_db_instance" "postgres" {
  engine                     = "postgres"
  engine_version             = "12.3"
  identifier                 = local.full_name
  instance_class             = var.db_instance_class
  allocated_storage          = var.db_storage
  username                   = data.aws_ssm_parameter.database_username.value
  password                   = data.aws_ssm_parameter.database_password.value
  storage_type               = "gp2"
  backup_retention_period    = "7"
  skip_final_snapshot        = true
  maintenance_window         = "sun:01:50-sun:02:20"
  backup_window              = "02:47-03:17"
  auto_minor_version_upgrade = false
  publicly_accessible        = false
  ca_cert_identifier         = "rds-ca-2019"

  vpc_security_group_ids = concat(
    var.db_security_group_ids,
    [aws_security_group.postgres_access.id],
  )

  db_subnet_group_name = aws_db_subnet_group.db.name

  tags = local.common_tags
}