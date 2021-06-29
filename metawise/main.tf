resource "aws_cloudwatch_log_subscription_filter" "filters" {
  name            = var.log_group_name
  role_arn        = aws_iam_role.cwl.arn
  log_group_name  = aws_cloudwatch_log_group.demo.name
  filter_pattern  = var.filter_pattern
  destination_arn = aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn
}

resource "aws_iam_role_policy" "permissionsforcwl" {
  role   = aws_iam_role.cwl.id
  policy = data.aws_iam_policy_document.cloudwatch.json
}

resource "aws_iam_role_policy" "permissionsforfirehose" {
  role   = aws_iam_role.firehosetos3.id
  policy = data.aws_iam_policy_document.firehose.json
}

resource "aws_iam_role" "cwl" {
  name = "${var.cloudwatch_name}-CWLTOKINESIS"

  assume_role_policy = <<EOF
{
    "Statement": {
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.${data.aws_region.current.name}.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
}
EOF
}

resource "aws_iam_role" "firehosetos3" {
  name = "${var.cloudwatch_name}-FIREHOSETOS3-${upper(var.region_desc)}"

  assume_role_policy = <<EOF
{
    "Statement": {
      "Effect": "Allow",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  }
EOF
}

resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = var.cloudwatch_name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehosetos3.arn
    bucket_arn = aws_s3_bucket.log_bucket.arn
  }

  server_side_encryption {
    enabled = false
  }

  tags = var.common_tags
}

resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = aws_s3_bucket.log_bucket.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "s3:GetBucketAcl",
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::${var.log_bucket}",
            "Principal": { "Service": "logs.${data.aws_region.current.name}.amazonaws.com" }
        },
        {
            "Action": "s3:PutObject" ,
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::${var.log_bucket}/*",
            "Condition": { "StringEquals": { "s3:x-amz-acl": "bucket-owner-full-control" } },
            "Principal": { "Service": "logs.${data.aws_region.current.name}.amazonaws.com" }
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket                  = aws_s3_bucket.log_bucket.id
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
}

resource "aws_cloudwatch_log_group" "demo" {
  name = "demo"

  tags = {
    Environment = "production"
    Application = "serviceA"
  }
}


resource "aws_s3_bucket" "log_bucket" {
  bucket = var.log_bucket
  acl    = "log-delivery-write"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.sse_algorithm
        kms_master_key_id = var.kms_master_key_id
      }
    }
  }

  tags = var.common_tags
  versioning {
    enabled = false
  }
}










