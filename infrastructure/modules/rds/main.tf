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

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.full_name}-postgress-access" })
  )
}

data "aws_secretsmanager_secret_version" "admin_creds" {
  secret_id = var.db_creds_secret_key
}

resource "aws_db_instance" "postgres" {
  engine                     = "postgres"
  engine_version             = var.db_engine_version
  identifier                 = "${local.full_name}${var.identifier_postfix}"
  instance_class             = var.db_instance_class
  allocated_storage          = var.db_storage
  username                   = jsondecode(data.aws_secretsmanager_secret_version.admin_creds.secret_string)["admin_username"]
  password                   = jsondecode(data.aws_secretsmanager_secret_version.admin_creds.secret_string)["admin_password"]
  storage_type               = "gp2"
  backup_retention_period    = "7"
  skip_final_snapshot        = true
  maintenance_window         = "sun:01:50-sun:02:20"
  backup_window              = "02:47-03:17"
  auto_minor_version_upgrade = false
  publicly_accessible        = false
  ca_cert_identifier         = var.db_cert_authority
  
  performance_insights_enabled = true

  vpc_security_group_ids = concat(
    var.db_security_group_ids,
    [aws_security_group.postgres_access.id],
  )

  db_subnet_group_name = aws_db_subnet_group.db.name

  tags = local.common_tags
}