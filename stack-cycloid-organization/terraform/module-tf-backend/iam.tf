resource "aws_iam_user" "org" {
  name = var.is_name
  path = "/organization/"

  tags = {
    Name = var.is_name
    role = "user"
  }
}

resource "aws_iam_user_login_profile" "org" {
  user    = aws_iam_user.org.name
}

resource "aws_iam_access_key" "org" {
  user    = aws_iam_user.org.name
}

data "aws_iam_policy_document" "org-s3" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.is_name}-terraform-remote-state"]
    actions   = ["s3:ListBucket"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.is_name}-terraform-remote-state/*"]

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:GenerateDataKey",
      "sts:GetCallerIdentity",
      "ec2:DescribeRegions",
      "kms:Decrypt",
    ]
  }
}

resource "aws_iam_user_policy" "org" {
  name = "cycloid-demo-user"
  user = aws_iam_user.org.name

  policy = data.aws_iam_policy_document.org-s3.json
}