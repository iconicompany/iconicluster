# Instance SMTP config so ZITADEL can send emails: registration verification,
# password reset, and Email OTP (2nd factor). This is an INSTANCE-level resource,
# so the terraform service user needs IAM_OWNER (instance Administrator), not just
# ORG_OWNER. Values come from variables (password in the gitignored terraform.tfvars).
resource "zitadel_email_provider_smtp" "default" {
  host           = "${var.SMTP_HOST}:${var.SMTP_PORT}"
  tls            = var.SMTP_TLS
  sender_address = var.SMTP_FROM
  sender_name    = var.SMTP_SENDER_NAME
  user           = var.SMTP_USER
  password       = var.SMTP_PASSWORD
  # make this the active SMTP provider so ZITADEL actually sends through it
  set_active = true
}
