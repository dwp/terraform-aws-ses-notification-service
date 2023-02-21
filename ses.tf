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
  name        = var.ses_send_mail_policy_name
  description = "Allow sending mail through SES"
  policy      = data.aws_iam_policy_document.ses_send_mail.json

  tags = merge(
    var.common_tags,
    {
      Name = "ses_send_mail"
    }
  )
}

resource "aws_ses_domain_identity" "domain_identity" {
  domain = var.domain
}

output "domain_identity" {
  value       = aws_ses_domain_identity.domain_identity.domain
  description = "Domain identity"
}

output "domain_identity_verification_token" {
  value       = aws_ses_domain_identity.domain_identity.verification_token
  description = "Domain identity token"
}
