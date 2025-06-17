#######################
# AWS Systems Manager #
#######################

# Get secrets from SSM

variable "ssm_secret_path" {
  default = ""
}

data "aws_ssm_parameters_by_path" "secrets" {
  path = local.ssm_secret_path
}

locals {
  # SSM path that contains envvars
  ssm_secret_path = var.ssm_secret_path != "" ? var.ssm_secret_path : "/${var.organization}/${var.project}/${var.env}"

  # To container format [{ name = "PASSWORD", valueFrom = "arn:aws:ssm:eu-west-1:awsExampleAccountID:parameter/project/env/PASSWORD" }]
  # Get the SSM arns and translate it to container env var format
  app_env_variables_secret = [for secret in data.aws_ssm_parameters_by_path.secrets.arns : { name = regex("/([^/]+)$", secret)[0], valueFrom = secret }]
}
