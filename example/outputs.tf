output "bucket_id" {
  value       = module.ses_notification_service.ses_mailer_bucket.id
  description = "SES Bucket ID"
}

output "lambda_arn" {
  value       = module.ses_notification_service.sns_to_ses_mailer_lambda_arn
  description = "Lambda arn"
}
