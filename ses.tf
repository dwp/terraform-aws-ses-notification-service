data "aws_iam_policy_document" "ses_send_mail" {
  statement {

    actions = [
      "ses:SendRawEmail",
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "ses_send_mail" {
  name        = "ses_send_mail"
  description = "Allow sending mail through SES"
  policy      = data.aws_iam_policy_document.ses_send_mail.json
}

resource "aws_ses_domain_identity" "domain_identity" {
  domain = var.domain
}

output "domain_identity" {
  value = aws_ses_domain_identity.domain_identity.domain
}

output "domain_identity_verification_token" {
  value = aws_ses_domain_identity.domain_identity.verification_token
}
