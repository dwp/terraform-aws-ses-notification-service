# terraform-aws-ses-notification-service
Terraform module that creates a service to receive notifications and distribute emails via AWS SES


## Usage
Note: Lambda Zip file can be sourced from https://github.com/dwp/aws-sns-to-ses-mailer/releases
```hcl
module "ses_notification_service" {
  source = "dwp/ses-notification-service/aws"

  domain = "example.com"
  region = "eu-west-2"
  lambda_sns_to_ses_mailer_zip = {
    base_path = ".",
    file_name   = "aws-sns-to-ses-mailer-0.0.1.zip"
  }
}
```
## Examples
The following example creates the notification service, SNS topic, email template, and distribution list.<br/>
Notifications published to SNS topic will then be emailed to the distribution list.

### Enable S3 Access Logging
```hcl
module "ses_notification_service" {
  source = "dwp/ses-notification-service/aws"
  bucket_access_logging = [
    {
      target_bucket = "my_access_logs_bucket_id"
      target_prefix = "s3Logs/ses_notification_service/"
    },
  ]

  domain = "example.com"
  region = "eu-west-2"
  lambda_sns_to_ses_mailer_zip = {
    base_path = ".",
    file_name   = "aws-sns-to-ses-mailer-0.0.1.zip"
  }
}
```

### Complete Service Example
```hcl
module "ses_notification_service" {
  source = "dwp/ses-notification-service/aws"

  domain = "example.com"
  region = "eu-west-2"
  lambda_sns_to_ses_mailer_zip = {
    base_path = ".",
    file_name   = "aws-sns-to-ses-mailer-0.0.1.zip"
  }
}

resource "aws_s3_bucket_object" "mailing_list" {
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
}

resource "aws_sns_topic" "danz_zuper_zervice" {
  name = "danz_zuper_zervice"
  display_name = "Danz Zuper Zervice - ${terraform.workspace}"
}

resource "aws_sns_topic_subscription" "sns_to_ses_mailer_lambda" {
  topic_arn = "${aws_sns_topic.danz_zuper_zervice.arn}"
  protocol  = "lambda"
  endpoint  = "${module.ses_notification_service.sns_to_ses_mailer_lambda_arn}"
}

resource "aws_lambda_permission" "ses_mailer" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${module.ses_notification_service.sns_to_ses_mailer_lambda_arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.danz_zuper_zervice.arn}"
}
```

### SNS Message Example
SNS message needs to in JSON format (not raw)
```json
{
  "default": "message-body",
  "email": "message-body",
  "lambda": "{\"ses_mailer\":{\"bucket\":\"ses_notification_service\",\"mailing_list\":\"mailing_list.csv.gz\",\"recipients\": [{\"email_address\": \"user-name@example.com\", \"name\": \"User Name\"}],\"from_local_part\": \"no-reply\",\"html_template\":\"mail_template.html\",\"plain_text_template\": \"\",\"template_variables\": {}}}",
  "https": "message-body"
}
```
