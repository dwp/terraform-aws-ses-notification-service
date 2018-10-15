resource "aws_lambda_function" "sns_to_ses_mailer" {
  filename = "${var.lambda_sns_to_ses_mailer_zip["base_path"]}/${var.lambda_sns_to_ses_mailer_zip["file_name"]}"
  function_name = "sns_to_ses_mailer"
  role = "${aws_iam_role.lambda_sns_to_ses_mailer.arn}"
  handler = "sns_to_ses_mailer.lambda_handler"
  runtime = "python3.6"
  source_code_hash = "${base64sha256(file(format("%s/%s",var.lambda_sns_to_ses_mailer_zip["base_path"],var.lambda_sns_to_ses_mailer_zip["file_name"])))}"
  publish = true
  timeout = 300
  environment {
    variables = {
      LOG_LEVEL = "${var.log_level}"
      REGION = "${var.region}"
      MAX_THREADS  = "${var.max_threads}"
      SENDING_DOMAIN = "${var.domain}"
    }
  }
  depends_on = ["aws_cloudwatch_log_group.sns_to_ses_mailer"]
}

resource "aws_iam_role" "lambda_sns_to_ses_mailer" {
  name = "lambda_sns_to_ses_mailer"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_policy.json}"
}

resource "aws_iam_role_policy_attachment" "lambda_sns_to_ses_mailer_xray" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
  role       = "${aws_iam_role.lambda_sns_to_ses_mailer.name}"
}

resource "aws_iam_role_policy_attachment" "lambda_sns_to_ses_mailer_send_mail" {
  policy_arn = "${aws_iam_policy.ses_send_mail.arn}"
  role       = "${aws_iam_role.lambda_sns_to_ses_mailer.name}"
}

resource "aws_iam_role_policy_attachment" "lambda_sns_to_ses_mailer_access_s3" {
  policy_arn = "${aws_iam_policy.ses_send_mail_read_s3.arn}"
  role       = "${aws_iam_role.lambda_sns_to_ses_mailer.name}"
}

resource "aws_iam_role_policy_attachment" "lambda_write_cloud_watch_logs" {
  policy_arn = "${aws_iam_policy.write_cloud_watch_logs.arn}"
  role = "${aws_iam_role.lambda_sns_to_ses_mailer.name}"
}

resource "aws_cloudwatch_log_group" "sns_to_ses_mailer" {
  name              = "/aws/lambda/sns_to_ses_mailer"
  retention_in_days = "${var.log_retention_days}"
}

output "sns_to_ses_mailer_lambda_arn" {
  value = "${aws_lambda_function.sns_to_ses_mailer.arn}"
}
