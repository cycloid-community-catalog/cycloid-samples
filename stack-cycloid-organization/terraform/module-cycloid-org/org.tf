resource "cycloid_organization" "org" {
  name                   = var.env
  organization_canonical = var.cycloid_root_org_canonical

  lifecycle {
    ignore_changes = [organization_canonical]
  }
}