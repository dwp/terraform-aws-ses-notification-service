variable "domain" {
  type        = string
  description = "The domain name to add to SES identities for sending emails from"
}

variable "region" {
  type        = string
  description = "AWS region used by Lambda to communicate with S3 and SES. This should match the AWS provider region"
}

variable "lambda_sns_to_ses_mailer_zip" {
  type        = map(string)
  description = "Local path to SES Mailer release: https://github.com/dwp/aws-sns-to-ses-mailer/releases"
  default = {
    base_path = ".",
    file_name = "aws-sns-to-ses-mailer-0.0.1.zip"
  }
}

variable "log_level" {
  type        = string
  description = "Logging level for Lambda"
  default     = "info"
}

variable "log_retention_days" {
  type        = string
  description = "Number of days to hold logs for"
  default     = "180"
}

variable "max_threads" {
  type        = string
  description = "The number of parrallel threads the Lambda can use to send messages to SES. A single thread should handle few hundred thousand."
  default     = "1"
}

variable "bucket_name" {
  type        = string
  description = "Name of S3 bucket for storing mailing lists and email templates."
  default     = "ses_notification_service"
}

variable "bucket_access_logging" {
  type        = list(map(string))
  description = "To enable access loging on the mailing list and email templates bucket pass in a list of a map of target_bucket and target_prefix"
  default     = []
}

variable "common_tags" {
  default = {}
}
