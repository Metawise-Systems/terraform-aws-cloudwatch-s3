data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    actions   = ["firehose:*"]
    resources = ["arn:aws:firehose:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }

  statement {
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.cwl.arn]
  }
}

data "aws_iam_policy_document" "firehose" {
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
    "s3:PutObject"]

    resources = [
      "${aws_s3_bucket.log_bucket.arn}",
    "${aws_s3_bucket.log_bucket.arn}/*"]
  }
}

data "aws_region" "current" {}

