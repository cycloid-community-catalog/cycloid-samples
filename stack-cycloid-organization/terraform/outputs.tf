output "is_name" {
  value     = var.is_name
}

output "bucket_name" {
  value = module.tf-backend.bucket_name
}

output "iam_user_password" {
  value = module.tf-backend.iam_user_password
  sensitive = true
}

output "iam_user_access_key" {
  value = module.tf-backend.iam_user_access_key
}

output "iam_user_secret_key" {
  value = module.tf-backend.iam_user_secret_key
  sensitive = true
}

output "aws_private_key_openssh" {
  value     = module.tf-backend.aws_private_key_openssh
  sensitive = true
}

output "aws_public_key_openssh" {
  value     = module.tf-backend.aws_public_key_openssh
  sensitive = true
}


