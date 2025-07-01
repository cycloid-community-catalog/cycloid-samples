###

# postgres

###


data "aws_vpc" "vpc" {
  tags = {
    Name = var.vpc_id
  }
}

# data "aws_vpc" "vpc" {
#   id = var.vpc_id
# }

# variable "database_subnet_group_name" {}
locals {
  # database_subnet_group_name = data.aws_vpc.vpc.tags["Name"]
  database_subnet_group_name = var.vpc_id
  postgres_identifier        = local.uniqname
}

variable "postgres_engine_version" {
  default = "17"
}

variable "postgres_type" {}
variable "postgres_multiaz" {
  default = false
}
# variable "postgres_disk_size" {
#   default = 20
# }

variable "postgres_allow_major_version_upgrade" {
  default = true
}

resource "random_password" "postgres_password" {
  length  = 64
  special = false
}

variable "postgres_username" {
  default = "digit"
}

variable "postgres_database" {
  default = "spring"
}

variable "postgres_backup_retention" {
  default = 7
}

variable "postgres_skip_final_snapshot" {
  default = true
}

resource "aws_security_group" "postgres" {
  name        = local.prefix_name
  description = "postgres ${var.env} for ${var.project}"
  # vpc_id      = var.vpc_id
  vpc_id = data.aws_vpc.vpc.id

  tags = {
    Name = local.prefix_name
    role = "postgres"
  }
}

resource "aws_rds_cluster" "app" {
  cluster_identifier = local.postgres_identifier
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned"
  database_name      = var.postgres_database
  master_username    = var.postgres_username
  master_password    = random_password.postgres_password.result
  storage_encrypted  = true
  # allocated_storage               = var.postgres_disk_size
  # iops                            = var.postgres_disk_size >= 400 ? 12000 : null
  # storage_type                    = "io1"
  allow_major_version_upgrade  = var.postgres_allow_major_version_upgrade
  engine_version               = var.postgres_engine_version
  apply_immediately            = true
  preferred_maintenance_window = "tue:06:00-tue:07:00"
  preferred_backup_window      = "02:00-04:00"
  backup_retention_period      = var.postgres_backup_retention
  copy_tags_to_snapshot        = true
  final_snapshot_identifier    = local.postgres_identifier
  skip_final_snapshot          = var.postgres_skip_final_snapshot
  # db_cluster_parameter_group_name = aws_db_parameter_group.optimized_postgres.id
  db_subnet_group_name = local.database_subnet_group_name

  vpc_security_group_ids = [aws_security_group.postgres.id]

  tags = {
    Name = local.prefix_name
    role = "postgres"
  }
}


resource "aws_rds_cluster_instance" "app" {
  cluster_identifier = aws_rds_cluster.app.id
  engine             = aws_rds_cluster.app.engine
  engine_version     = aws_rds_cluster.app.engine_version
  instance_class     = var.postgres_type

  tags = {
    Name = local.postgres_identifier
    role = "postgres"
  }
  # multi_az                    = var.postgres_multiaz
}

# Outputs

output "postgres_address" {
  value = aws_rds_cluster.app.endpoint
}

output "postgres_port" {
  value = aws_rds_cluster.app.port
}

output "postgres_database" {
  value = aws_rds_cluster.app.database_name
}

output "postgres_username" {
  value = aws_rds_cluster.app.master_username
}

output "postgres_password" {
  value     = random_password.postgres_password.result
  sensitive = true
}

locals {
  app_env_variables_postgres = {
    # "POSTGRES_URL" : "jdbc:postgres://${var.postgres_username}:${random_password.postgres_password.result}@${aws_rds_cluster.app.endpoint}:${aws_rds_cluster.app.port}/${var.postgres_database}"
    "POSTGRES_URL" : "jdbc:postgres://${aws_rds_cluster.app.endpoint}:${aws_rds_cluster.app.port}/${var.postgres_database}"
    "SPRING_PROFILES_ACTIVE" : "postgresql"
    "POSTGRES_USER" : var.postgres_username
    "POSTGRES_PASS" : random_password.postgres_password.result
    # Extra var to debug
    "POSTGRES_HOST" : aws_rds_cluster.app.endpoint
    "POSTGRES_PORT" : aws_rds_cluster.app.port
    "DATABASE_NAME" : var.postgres_database
  }
}
