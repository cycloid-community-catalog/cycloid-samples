output "aws_rds_cluster_id" {
  value = aws_rds_cluster.app.id
}

output "aws_security_group_id" {
  value = aws_security_group.postgres.id
}

output "ssm_secret_path" {
  value = local.ssm_path
}
