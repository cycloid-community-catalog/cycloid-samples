##############
# IAM / Role #
##############
data "aws_iam_policy_document" "assume_role" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# # Role used by ecs task to get access to ssm ...
resource "aws_iam_role" "ecs_task_execution" {
  name               = "${local.prefix_name}-ecs"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# # AWS policy to allow ECR access and Cloudwatch Logs
# https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonECSTaskExecutionRolePolicy.html
# "ecr:GetAuthorizationToken",
# "ecr:BatchCheckLayerAvailability",
# "ecr:GetDownloadUrlForLayer",
# "ecr:BatchGetImage",
# "logs:CreateLogStream",
# "logs:PutLogEvents"

resource "aws_iam_role_policy_attachment" "ecs_to_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution.name
}

# # AWS policy to allow ECR access
# # https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonSSMReadOnlyAccess.html
# # "ssm:Describe*",
# # "ssm:Get*",
# # "ssm:List*"
resource "aws_iam_role_policy_attachment" "ecs_to_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  role       = aws_iam_role.ecs_task_execution.name
}

# # If needed to limitate secrets access
# # data "aws_iam_policy_document" "ssm_policy" {
# #   statement {
# #     actions = [
# #       "ssm:GetParameter",
# #       "ssm:GetParameters",
# #       "ssm:GetParametersByPath"
# #     ]
# #     resources = [
# #       "arn:aws:ssm:<region>:<account-id>:parameter/secret1",
# #       "arn:aws:ssm:<region>:<account-id>:parameter/secret2"
# #     ]
# #     effect = "Allow"
# #   }
# # }
# # resource "aws_iam_policy" "ssm_policy" {
# #   name        = "${local.prefix_name}-ssm"
# #   policy      = data.aws_iam_policy_document.ssm_policy.json
# # }
# # resource "aws_iam_role_policy_attachment" "ssm_policy" {
# #   policy_arn = aws_iam_policy.ssm_policy.arn
# #   role       = aws_iam_role.ecs_task_execution.name
# # }


# additionnal policies
# ssmmessages needed for aws ecs execute-command
data "aws_iam_policy_document" "extra" {
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}
resource "aws_iam_policy" "extra" {
  name   = "${local.prefix_name}-ssm"
  policy = data.aws_iam_policy_document.extra.json
}
resource "aws_iam_role_policy_attachment" "extra" {
  policy_arn = aws_iam_policy.extra.arn
  role       = aws_iam_role.ecs_task_execution.name
}
