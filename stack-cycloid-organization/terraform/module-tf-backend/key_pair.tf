resource "tls_private_key" "aws_generated_key" {
  algorithm   = "ED25519"
}

resource "aws_key_pair" "aws_generated_key" {
  key_name   = var.is_name
  public_key = tls_private_key.aws_generated_key.public_key_openssh
}
