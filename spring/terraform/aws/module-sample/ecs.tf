####################
# Centralized logs #
####################
resource "aws_cloudwatch_log_group" "cluster" {
  name              = "${var.project}_${var.env}_${var.component}"
  retention_in_days = 90
}

####################
# ECS Cluster      #
####################
resource "aws_ecs_cluster" "cluster" {
  name = local.prefix_name

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = false
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.cluster.name
      }
    }
  }
}

######################
# EService namespace #
######################
resource "aws_service_discovery_http_namespace" "cluster" {
  name        = local.prefix_name
  description = "${local.prefix_name} used to connect ecs tasks"
}

####################
# LoadBalancer     #
####################
resource "aws_security_group" "alb" {
  name        = local.prefix_name
  description = "Used by ECS ${local.prefix_name}"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "ecs" {
  name                             = replace("${local.prefix_name}", var.nameregex, "")
  security_groups                  = [aws_security_group.alb.id]
  subnets                          = local.public_subnets
  enable_cross_zone_load_balancing = true
  idle_timeout                     = 600
}

output "ecs_alb_dns_name" {
  value = aws_alb.ecs.dns_name
}

output "cluster_id" {
  value = aws_ecs_cluster.cluster.id
}

output "cluster_arn" {
  value = aws_ecs_cluster.cluster.arn
}
