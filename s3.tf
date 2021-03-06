resource "aws_kms_key" "ses_mailer_bucket_cmk" {
  description             = "SES Mailer Bucket Master Key"
  deletion_window_in_days = 14
  is_enabled              = true
  enable_key_rotation     = true

  tags = merge(
    var.common_tags,
    {
      Name = "ses_mailer_bucket_cmk"
    }
  )
}

resource "aws_kms_alias" "ses_mailer_bucket_cmk_alias" {
  target_key_id = aws_kms_key.ses_mailer_bucket_cmk.key_id
  name          = "alias/ses_mailer_bucket_cmk"
}

resource "aws_s3_bucket" "ses_mailer_bucket" {
  bucket = var.bucket_name
  acl    = "private"

  dynamic "logging" {
    for_each = var.bucket_access_logging
    content {
      target_bucket = logging.value.target_bucket
      target_prefix = logging.value.target_prefix
    }
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = 30
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.ses_mailer_bucket_cmk.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name = "ses-mailer-bucket"
    }
  )
}

data "aws_iam_policy_document" "ses_send_mail_read_s3" {
  statement {
    sid    = "SendMailS3BucketReadAccess"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "kms:Decrypt",
    ]

    resources = [
      aws_s3_bucket.ses_mailer_bucket.arn,
      "${aws_s3_bucket.ses_mailer_bucket.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "ses_send_mail_read_s3" {
  name        = "ses_send_mail_read_s3"
  description = "Allow retreiving mail templates and mailing lists from S3"
  policy      = data.aws_iam_policy_document.ses_send_mail_read_s3.json

  tags = merge(
    var.common_tags,
    {
      Name = "ses_send_mail_read_s3"
    }
  )
}

output "ses_mailer_bucket" {
  value = {
    id  = aws_s3_bucket.ses_mailer_bucket.id
    arn = aws_s3_bucket.ses_mailer_bucket.arn
  }
}
