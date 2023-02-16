provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::${var.test_account}:role/${var.assume_role}"

  }

}

variable "assume_role" {
  type        = string
  default     = "ci"
  description = "Role to assume"
}

variable "test_account" {
  type        = string
  description = "Test AWS Account number"

}


module "ses_notification_service" {
  source = "../"
  /* source = "dwp/ses-notification-service/aws" */

  domain = "ses-example.com"
  region = "eu-west-1"
  lambda_sns_to_ses_mailer_zip = {
    base_path = ".",
    file_name = "aws-sns-to-ses-mailer-0.0.28.zip"
  }
  bucket_name                      = "dwx-test-ses-bucket"
  cw_logs_policy_name              = "test_ses_cwlogs_policy"
  lambda_mailer_role_name          = "test_lambda_sns_to_ses_mailer"
  lambda_mailer_cw_log_group_name  = "/test/aws/lambda/sns_to_ses_mailer"
  ses_mailer_bucket_cmk            = "alias/test_ses_mailer_bucket_cmk"
  ses_send_mail_policy_name        = "test_ses_send_mail"
  ses_lambda_func_name             = "test_sns_to_ses_mailer"
  ses_send_mail_reads3_policy_name = "test_ses_send_mail_read_s3"
}

/* resource "aws_s3_bucket_object" "mailing_list" {
  bucket = "${module.ses_notification_service.ses_mailer_bucket}"
  key    = "mailing_list.csv.gz"
  source = "mailing_list.csv.gz"
  etag   = "${md5(file("mailing_list.csv.gz"))}"
}

resource "aws_s3_bucket_object" "email_template" {
  bucket = "${module.ses_notification_service.ses_mailer_bucket}"
  key    = "mail_template.html"
  source = "mail_template.html"
  etag   = "${md5(file("mail_template.html"))}"
} */

resource "aws_sns_topic" "test_ses_sns" {
  name         = "test_ses_sns"
  display_name = "Test SES SNS Topic - ${terraform.workspace}"
}

resource "aws_sns_topic_subscription" "sns_to_ses_mailer_lambda" {
  topic_arn = aws_sns_topic.test_ses_sns.arn
  protocol  = "lambda"
  endpoint  = module.ses_notification_service.sns_to_ses_mailer_lambda_arn
}

resource "aws_lambda_permission" "ses_mailer" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.ses_notification_service.sns_to_ses_mailer_lambda_arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.test_ses_sns.arn
}
