#######################
# AWS Systems Manager #
#######################

resource "aws_ssm_parameter" "app_env_variables_secret" {
  # Remove key if value is empty
  # Use nonsensitive because of error: Sensitive values, or values derived from sensitive values, cannot be used
  # as for_each arguments. If used, the sensitive value could be exposed as a resource instance key.
  # for_each = nonsensitive({ for k, v in local.merged_internal_secret : k => v if v != "" })
  for_each = local.merged_internal_secret

  name        = "${local.ssm_path}/${each.key}"
  description = "${var.project} ${var.env} ${each.key}"
  type        = "SecureString"
  tier        = "Standard"
  value       = each.value
}

locals {
  ssm_path = "/${var.organization}/${var.project}/${var.env}"
  # Merge local/internal secrets
  merged_internal_secret = merge(local.app_env_variables_postgres)
}
