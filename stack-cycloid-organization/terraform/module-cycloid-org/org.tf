resource "cycloid_organization" "org" {
  name                   = var.dg_name
  organization_canonical = var.cy_org

  lifecycle {
    ignore_changes = [organization_canonical]
  }
}