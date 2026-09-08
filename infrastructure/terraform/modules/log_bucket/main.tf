locals {
  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = var.bucket_name
  tags   = local.tags
}

resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    id     = "log-retention"
    status = "Enabled"
    filter {
      prefix = "logs/"
    }
    transition {
      days          = var.standard_ia_transition_days
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = var.glacier_transition_days
      storage_class = "GLACIER"
    }
    expiration {
      days = var.log_retention_days
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

data "aws_iam_policy_document" "deny_insecure_transport" {
  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.logs.arn, "${aws_s3_bucket.logs.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.deny_insecure_transport.json
}

data "aws_iam_policy_document" "collector" {
  statement {
    sid       = "WriteLogObjects"
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:AbortMultipartUpload"]
    resources = ["${aws_s3_bucket.logs.arn}/logs/*"]
  }
  statement {
    sid       = "ReadBucketLocation"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation"]
    resources = [aws_s3_bucket.logs.arn]
  }
}

resource "aws_iam_policy" "collector" {
  name        = "${var.project_name}-${var.environment}-collector-s3-write"
  description = "Least-privilege access for the OpenTelemetry Collector S3 exporter."
  policy      = data.aws_iam_policy_document.collector.json
  tags        = local.tags
}

data "aws_iam_policy_document" "assume_collector" {
  count = length(var.collector_role_principal_arns) > 0 ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = var.collector_role_principal_arns
    }
  }
}

resource "aws_iam_role" "collector" {
  count              = length(var.collector_role_principal_arns) > 0 ? 1 : 0
  name               = "${var.project_name}-${var.environment}-collector"
  assume_role_policy = data.aws_iam_policy_document.assume_collector[0].json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "collector" {
  count      = length(var.collector_role_principal_arns) > 0 ? 1 : 0
  role       = aws_iam_role.collector[0].name
  policy_arn = aws_iam_policy.collector.arn
}
