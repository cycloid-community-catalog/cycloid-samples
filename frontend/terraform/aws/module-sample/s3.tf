# spring Audit Bucket
resource "aws_s3_bucket" "spring" {
  bucket = "${local.prefix_name}-statics"

  tags = {
    Name = "${local.prefix_name}-statics"
  }
}
