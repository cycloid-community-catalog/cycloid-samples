resource "github_repository" "cycloid-demo" {
  name        = var.dg_name
  description = "Repo for ${var.dg_name} free trial"

  visibility = "private"
  template {
    owner                = "cycloid-community-catalog"
    repository           = "cycloid-samples"
  }
}

resource "github_branch" "config" {
  repository = github_repository.cycloid-demo.name
  branch     = "config"
}

resource "tls_private_key" "github_generated_key" {
  algorithm   = "ED25519"
}

resource "github_repository_deploy_key" "cycloid-demo" {
  title      = var.dg_name
  repository = github_repository.cycloid-demo.name
  key        = tls_private_key.github_generated_key.public_key_openssh
  read_only  = false
}