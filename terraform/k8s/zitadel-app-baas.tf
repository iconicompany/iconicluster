# Per-app service account for the "baas" app (/home/slavb18/moon/work-iq/baas).
# Drives headless auth via the ZITADEL API: register users, email-code login
# (Session API), and finalizing OIDC auth requests. Each app gets its own account.
resource "zitadel_machine_user" "baas" {
  org_id      = local.ZITADEL_ORG_ID
  user_name   = "baas"
  name        = "baas service account"
  description = "Backend service account for the baas app (headless auth)"
}

resource "zitadel_machine_key" "baas" {
  org_id   = local.ZITADEL_ORG_ID
  user_id  = zitadel_machine_user.baas.id
  key_type = "KEY_TYPE_JSON"
}

# IAM_LOGIN_CLIENT: required for the Session API and finalizing OIDC auth requests.
resource "zitadel_instance_member" "baas_login_client" {
  user_id = zitadel_machine_user.baas.id
  roles   = ["IAM_LOGIN_CLIENT"]
}

# ORG_USER_MANAGER: create/verify users (registration, email verification, OTP email).
resource "zitadel_org_member" "baas_user_manager" {
  org_id  = local.ZITADEL_ORG_ID
  user_id = zitadel_machine_user.baas.id
  roles   = ["ORG_USER_MANAGER"]
}

# JSON service-account key (jwt-profile) for the baas app. Sensitive; written to the
# baas project's gitignored .zitadel/baas-key.json, not committed here.
output "baas_key" {
  value     = zitadel_machine_key.baas.key_details
  sensitive = true
}
