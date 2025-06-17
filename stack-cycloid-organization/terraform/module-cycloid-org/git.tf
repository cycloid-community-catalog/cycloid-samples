resource "cycloid_credential" "git-ssh" {
  name                   = "git-cycloid"
  description            = "SSH private key allowing access to a git repository used as Catalog and Config repositories for your Cycloid organization."
  organization_canonical = cycloid_organization.org.canonical
  path                   = "git-cycloid"
  canonical              = "git-cycloid"

  type = "ssh"
  body = {
    ssh_key = chomp(var.cycloid_git_ssh_key)
  }
}

resource "cycloid_catalog_repository" "catalog_repo" {
  name                   = "DIGIT Repository"
  branch                 = "stacks"
  url                    = var.cycloid_git_url
  credential_canonical   = cycloid_credential.git-ssh.canonical
  organization_canonical = cycloid_organization.org.canonical
}

resource "cycloid_config_repository" "config_repo" {
  name                   = "DIGIT Repository"
  branch                 = "config"
  default                = true
  url                    = var.cycloid_git_url
  credential_canonical   = cycloid_credential.git-ssh.canonical
  organization_canonical = cycloid_organization.org.canonical
}
