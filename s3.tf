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
  name          = var.ses_mailer_bucket_cmk
}

resource "aws_s3_bucket" "ses_mailer_bucket" {
  bucket = var.bucket_name

  dynamic "logging" {
    for_each = var.bucket_access_logging
    content {
      target_bucket = logging.value.target_bucket
      target_prefix = logging.value.target_prefix
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name = "ses-mailer-bucket"
    }
  )
}

resource "aws_s3_bucket_acl" "example_bucket_acl" {
  bucket = aws_s3_bucket.ses_mailer_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ses_mailer_bucket_enc" {
  bucket = aws_s3_bucket.ses_mailer_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.ses_mailer_bucket_cmk.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.ses_mailer_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "example" {
  depends_on = [aws_s3_bucket_versioning.versioning]
  bucket     = aws_s3_bucket.ses_mailer_bucket.id

  rule {
    id = "config"

    filter {
      prefix = "config/"
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    status = "Enabled"
  }
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
  name        = var.ses_send_mail_reads3_policy_name
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
  description = "SES Mailer Bucket"
}
