variable "alarm_period" {
  default = 60
}
variable "alarm_evaluation_period" {
  default = 1
}

resource "aws_cloudwatch_metric_alarm" "alarm_rds_DatabaseConnections_writer" {
  alarm_name          = "${local.prefix_name}-RDS-writer-DatabaseConnections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_period
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = "500"
  alarm_description   = "RDS Maximum connection Alarm for ${local.prefix_name} writer"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.app.id
    Role                = "WRITER"
  }
}

# resource "aws_cloudwatch_metric_alarm" "alarm_rds_DatabaseConnections_reader" {
#   alarm_name          = "${local.prefix_name}-rds-reader-DatabaseConnections"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = var.alarm_evaluation_period
#   metric_name         = "DatabaseConnections"
#   namespace           = "AWS/RDS"
#   period              = var.alarm_period
#   statistic           = "Maximum"
#   threshold           = "500"
#   alarm_description   = "RDS Maximum connection Alarm for ${local.prefix_name} reader(s)"

#   dimensions = {
#     DBClusterIdentifier = aws_rds_cluster.app.id
#     Role                = "READER"
#   }
# }

resource "aws_cloudwatch_metric_alarm" "alarm_rds_CPU_writer" {
  alarm_name          = "${local.prefix_name}-RDS-writer-CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.alarm_period
  statistic           = "Maximum"
  threshold           = "85"
  alarm_description   = "RDS CPU Alarm for ${local.prefix_name} writer"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.app.id
    Role                = "WRITER"
  }
}

# resource "aws_cloudwatch_metric_alarm" "alarm_rds_CPU_reader" {
#   alarm_name          = "${local.prefix_name}-rds-reader-CPU"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/RDS"
#   period              = var.alarm_period
#   statistic           = "Maximum"
#   threshold           = "85"
#   alarm_description   = "RDS CPU Alarm for ${local.prefix_name} reader(s)"

#   dimensions = {
#     DBClusterIdentifier = aws_rds_cluster.app.id
#     Role                = "READER"
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "alarm_rds_replica_lag" {
#   alarm_name          = "${local.prefix_name}-rds-reader-AuroraReplicaLag"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "5"
#   metric_name         = "AuroraReplicaLag"
#   namespace           = "AWS/RDS"
#   period              = var.alarm_period
#   statistic           = "Maximum"
#   threshold           = "2000"
#   alarm_description   = "RDS CPU Alarm for ${local.prefix_name}"

#   dimensions = {
#     DBClusterIdentifier = aws_rds_cluster.app.id
#     Role                = "READER"
#   }
# }

resource "aws_cloudwatch_metric_alarm" "cpu_credit_balance_too_low" {
  alarm_name          = "${local.prefix_name}-RDS-lowCPUCreditBalance"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUCreditBalance"
  namespace           = "AWS/RDS"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = "50"
  alarm_description   = "Average database CPU credit balance is too low, a negative performance impact is imminent."

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.app.id
  }
}
resource "aws_cloudwatch_metric_alarm" "memory_freeable_too_low" {
  alarm_name          = "${local.prefix_name}-RDS-lowFreeableMemory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = "256000000" // 256 MB
  alarm_description   = "Average database freeable memory is too low, performance may be negatively impacted."

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.app.id
  }
}

# other example: https://github.com/lorenzoaiello/terraform-aws-rds-alarms/blob/main/main.tf
