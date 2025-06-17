output "bucket_name" {
  value = "${var.is_name}-terraform-remote-state"
}

output "iam_user_password" {
  value = aws_iam_user_login_profile.org.password
  sensitive = true
}

output "iam_user_access_key" {
  value = aws_iam_access_key.org.id
}

output "iam_user_secret_key" {
  value = aws_iam_access_key.org.secret
  sensitive = true
}

output "aws_private_key_openssh" {
  value     = tls_private_key.aws_generated_key.private_key_openssh
  sensitive = true
}

output "aws_public_key_openssh" {
  value     = tls_private_key.aws_generated_key.public_key_openssh
  sensitive = true
}