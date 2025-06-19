resource "cycloid_organization" "org" {
  name                   = var.is_name
  organization_canonical = var.cy_org

  lifecycle {
    ignore_changes = [organization_canonical]
  }
}

# resource "cycloid_organization_member" "tf_org_member" {
#   email = "olivier.deturckheim@cycloid.io"
#   role_canonical = "organization-admin"
#   organization_canonical = cycloid_organization.org.canonical
# }