data "aws_iam_policy_document" "lambda_assume_policy" {
  statement {
    sid    = "LambdaApiAssumeRolePolicy"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = [
        "lambda.amazonaws.com",
      ]

      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "write_cloud_watch_logs" {
  "statement" {
    sid = "WriteCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }
}

resource "aws_iam_policy" "write_cloud_watch_logs" {
  name        = "WriteCloudWatchLogs"
  description = "Allow writing logs to CloudWatch"
  policy      = "${data.aws_iam_policy_document.write_cloud_watch_logs.json}"
}