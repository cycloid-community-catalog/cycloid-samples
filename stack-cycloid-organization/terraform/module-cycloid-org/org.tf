resource "cycloid_organization" "org" {
  name                   = var.is_name
  organization_canonical = var.cy_org

  lifecycle {
    ignore_changes = [organization_canonical]
  }
}