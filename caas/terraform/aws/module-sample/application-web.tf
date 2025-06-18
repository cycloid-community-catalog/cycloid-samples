####################
# WEB              #
####################

# mem & cpu are linked. See the limitation here:
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
variable "web_memory" {
  default = 1024
}

variable "web_cpu" {
  default = 256
}

variable "web_env" {
  default = {}
}

locals {
  web_env = [for k, v in var.web_env : { name = k, value = v }]
}

variable "web_task_port" {
  default = 8080
}
variable "deployment_minimum_healthy_percent" {
  default = 100
}

variable "web_image" {
  # default = "springcommunity/spring-framework-petclinic:latest"
  # default = "cycloid/spring-framework-petclinic:latest"
  default = "talset/spring-framework-petclinic"
}

variable "web_image_version" {
  default = "latest"
}

variable "web_image_digest" {
  default = ""
}

locals {
  web_image = var.web_image_digest == "" ? "${var.web_image}:${var.web_image_version}" : "${var.web_image}:${var.web_image_version}@${var.web_image_digest}"

  # Calculate the max to be one container more than desired
  # web_deployment_maximum_percent = (var.deployment_minimum_healthy_percent * (var.web_autoscaling_min + 1)) / var.web_autoscaling_min
  # deploy more than 1 containers at the same time
  web_deployment_maximum_percent = 300

  web_container_definition = [
    {
      name  = "${local.prefix_name}-web"
      image = local.web_image
      portMappings = [
        {
          containerPort = var.web_task_port
          hostPort      = var.web_task_port
        }
      ]
      # command     = split(" ", try(var.web_cmd, "start web"))
      essential   = true
      mountPoints = []
      volumesFrom = []
      environment = local.web_env
      secrets     = local.app_env_variables_secret

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.cluster.name
          awslogs-stream-prefix = "container"
          awslogs-region        = var.aws_region
        }
      }
    }
  ]
}

####################
# LoadBalancer     #
####################
# 443 by defaut to web
resource "aws_alb_listener" "web-443" {
  load_balancer_arn = aws_alb.ecs.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.spring.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.web-80.arn
  }
}

# 80 default to web
resource "aws_alb_listener" "web-80" {
  load_balancer_arn = aws_alb.ecs.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.web-80.arn
  }
}

# TargetGroup for ALBs
resource "aws_alb_target_group" "web-80" {
  name                          = "${local.uniqname}web80"
  port                          = var.web_task_port
  protocol                      = "HTTP"
  target_type                   = "ip"
  vpc_id                        = local.vpc_id
  load_balancing_algorithm_type = "round_robin"

  health_check {
    path     = "/"
    matcher  = "200"
    timeout  = 5
    interval = 10
  }

  stickiness {
    type    = "lb_cookie"
    enabled = true
  }

  deregistration_delay = 60
}


####################
# Security Groups  #
####################
resource "aws_security_group" "ecs_web" {
  name        = "${local.prefix_name}-ecs-web"
  description = "${local.prefix_name} ecs task web"
  vpc_id      = local.vpc_id

  # Allow ALB access to web
  ingress {
    from_port       = var.web_task_port
    to_port         = var.web_task_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.prefix_name}-ecs-web"
    role = "ecs-web"
  }
}

output "ecs_web_sg" {
  value = aws_security_group.ecs_web.id
}

####################
# ECS              #
####################

resource "aws_ecs_service" "web" {
  name                               = "${local.prefix_name}-web"
  cluster                            = aws_ecs_cluster.cluster.id
  task_definition                    = aws_ecs_task_definition.web.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = local.web_deployment_maximum_percent
  # Allow to connect inside the containers
  enable_execute_command = true

  health_check_grace_period_seconds = 300

  # Required to prevent the service from being replaced when the capacity provider strategy changes
  # https://registry.terraform.io/providers/hashicorp/aws/5.81.0/docs/resources/ecs_service#capacity_provider_strategy-1
  force_new_deployment = true

  launch_type = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_web.id]
    subnets          = local.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.web-80.arn
    container_name   = "${local.prefix_name}-web"
    container_port   = var.web_task_port
  }

  tags = {
    role = "web"
  }

  # Managed with autoscaling
  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_ecs_task_definition" "web" {
  family                   = "${local.prefix_name}-web"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.web_cpu
  memory                   = var.web_memory
  container_definitions    = jsonencode(local.web_container_definition)
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_execution.arn
}
