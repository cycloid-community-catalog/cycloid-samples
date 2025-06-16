# resource "cycloid_credential" "key_pair" {
#   name                   = "key-pair"
#   description            = "SSH Key Pair used in newly provisionned workloads."
#   organization_canonical = var.dg_name
#   path                   = "key-pair"
#   canonical              = "key-pair"

#   type = "ssh"
#   body = {
#     ssh_key = chomp(var.private_key_openssh)
#   }
# }