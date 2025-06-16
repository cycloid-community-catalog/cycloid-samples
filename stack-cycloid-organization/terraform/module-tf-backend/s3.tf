module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${var.dg_name}-terraform-remote-state"
  
  # To allow destruction of a non-empty bucket
  force_destroy = true

  tags = {
    Name = "${var.dg_name}-terraform-remote-state"
    role = "s3"
  }
}