output "aws_rds_cluster_id" {
  value = try(module.database.aws_rds_cluster_id, "")
}

output "aws_security_group_id" {
  value = try(module.database.aws_security_group_id, "")
}

output "ssm_secret_path" {
  value = try(module.database.ssm_secret_path, "")
}
