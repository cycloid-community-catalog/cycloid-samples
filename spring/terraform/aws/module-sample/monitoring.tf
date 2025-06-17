variable "alarm_period" {
  default = 60
}
variable "alarm_evaluation_period" {
  default = 1
}


# Free metrics not available
####################################
# Cloudwatch Alarm for ECS Cluster #
####################################

# resource "aws_cloudwatch_metric_alarm" "ecs-alert_High-CPUReservation" {
#   alarm_name          = "${local.prefix_name}-ECS-High_CPUResv"
#   comparison_operator = "GreaterThanOrEqualToThreshold"

#   period              = var.alarm_period
#   evaluation_periods  = var.alarm_evaluation_period
#   datapoints_to_alarm = 1

#   # second
#   statistic         = "Average"
#   threshold         = "80"
#   alarm_description = ""

#   metric_name = "CPUReservation"
#   namespace   = "AWS/ECS"
#   dimensions = {
#     ClusterName = aws_ecs_cluster.cluster.name
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "ecs-alert_Low-CPUReservation" {
#   alarm_name          = "${local.prefix_name}-ECS-Low_CPUResv"
#   comparison_operator = "LessThanThreshold"

#   period              = var.alarm_period
#   evaluation_periods  = var.alarm_evaluation_period
#   datapoints_to_alarm = 1

#   statistic         = "Average"
#   threshold         = "40"
#   alarm_description = ""

#   metric_name = "CPUReservation"
#   namespace   = "AWS/ECS"
#   dimensions = {
#     ClusterName = aws_ecs_cluster.cluster.name
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "ecs-alert_High-MemReservation" {
#   alarm_name          = "${local.prefix_name}-ECS-High_MemResv"
#   comparison_operator = "GreaterThanOrEqualToThreshold"

#   period              = var.alarm_period
#   evaluation_periods  = var.alarm_evaluation_period
#   datapoints_to_alarm = 1

#   statistic         = "Average"
#   threshold         = "80"
#   alarm_description = ""

#   metric_name = "MemoryReservation"
#   namespace   = "AWS/ECS"
#   dimensions = {
#     ClusterName = aws_ecs_cluster.cluster.name
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "ecs-alert_Low-MemReservation" {
#   alarm_name          = "${local.prefix_name}-ECS-Low_MemResv"
#   comparison_operator = "LessThanThreshold"

#   period              = var.alarm_period
#   evaluation_periods  = var.alarm_evaluation_period
#   datapoints_to_alarm = 1

#   statistic         = "Average"
#   threshold         = "40"
#   alarm_description = ""

#   metric_name = "MemoryReservation"
#   namespace   = "AWS/ECS"
#   dimensions = {
#     ClusterName = aws_ecs_cluster.cluster.name
#   }
# }

###############
# ECS Service #
###############

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  alarm_name          = "${local.prefix_name}-ECS-Service-cpu-high"
  alarm_description   = "ECS service cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_period
  period              = var.alarm_period
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    "ClusterName" = aws_ecs_cluster.cluster.name
    "ServiceName" = aws_ecs_service.web.name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_high" {
  alarm_name          = "${local.prefix_name}-ECS-Service-memory-high"
  alarm_description   = "ECS service memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_period
  period              = var.alarm_period
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  threshold           = "80"


  dimensions = {
    "ClusterName" = aws_ecs_cluster.cluster.name
    "ServiceName" = aws_ecs_service.web.name
  }
}

################
# LoadBalancer #
################

resource "aws_cloudwatch_metric_alarm" "httpcode_target_5xx_count" {
  alarm_name          = "${local.prefix_name}-ALB-target-high5XXCount"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_period
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Average API 5XX target group error code count is too high"

  dimensions = {
    "TargetGroup"  = aws_alb_target_group.web-80.arn_suffix
    "LoadBalancer" = aws_alb.ecs.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "httpcode_lb_5xx_count" {
  alarm_name          = "${local.prefix_name}-ALB-high5XXCount"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_period
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Average API 5XX load balancer error code count is too high"

  dimensions = {
    "LoadBalancer" = aws_alb.ecs.arn_suffix
  }
}

################
# TargetGroup  #
################

resource "aws_cloudwatch_metric_alarm" "target_response_time_average" {
  alarm_name          = "${local.prefix_name}-ALB-target-highResponseTime"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_period
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = "0.10"
  alarm_description   = format("Average API response time is greater than %s", "0.10")

  dimensions = {
    "TargetGroup"  = aws_alb_target_group.web-80.arn_suffix
    "LoadBalancer" = aws_alb.ecs.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "${local.prefix_name}-ALB-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_period
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period
  statistic           = "Minimum"
  threshold           = "0"
  alarm_description   = format("Unhealthy host count is greater than %s", "0")

  dimensions = {
    "TargetGroup"  = aws_alb_target_group.web-80.arn_suffix
    "LoadBalancer" = aws_alb.ecs.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "healthy_hosts" {
  alarm_name          = "${local.prefix_name}-ALB-healthy-hosts"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_period
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period
  statistic           = "Minimum"
  threshold           = "0"
  alarm_description   = format("Healthy host count is less than or equal to %s", "0")

  dimensions = {
    "TargetGroup"  = aws_alb_target_group.web-80.arn_suffix
    "LoadBalancer" = aws_alb.ecs.arn_suffix
  }
}
