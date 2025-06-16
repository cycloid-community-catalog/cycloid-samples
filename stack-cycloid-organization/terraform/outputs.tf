output "dg_name" {
  value     = var.dg_name
}

output "github_ssh_private_key" {
  value     = tls_private_key.github_generated_key.private_key_openssh
  sensitive = true
}

output "github_ssh_public_key" {
  value     = tls_private_key.github_generated_key.public_key_openssh
}

output "github_repository_ssh_url" {
  value = "git@github.com:cycloid-demo/${github_repository.cycloid-demo.name}.git"
}

output "bucket_name" {
  value = module.aws-cycloid-trial.bucket_name
}

output "iam_user_password" {
  value = module.aws-cycloid-trial.iam_user_password
  sensitive = true
}

output "iam_user_access_key" {
  value = module.aws-cycloid-trial.iam_user_access_key
}

output "iam_user_secret_key" {
  value = module.aws-cycloid-trial.iam_user_secret_key
  sensitive = true
}

output "aws_private_key_openssh" {
  value     = module.aws-cycloid-trial.aws_private_key_openssh
  sensitive = true
}

output "aws_public_key_openssh" {
  value     = module.aws-cycloid-trial.aws_public_key_openssh
  sensitive = true
}


