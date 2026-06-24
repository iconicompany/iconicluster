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

# OIDC client for the baas gateway (variant 4B: real ZITADEL tokens). The service
# account drives login via the Session API and finalizes auth requests for THIS client.
resource "zitadel_project" "baas" {
  name   = "baas"
  org_id = local.ZITADEL_ORG_ID
}

resource "zitadel_application_oidc" "baas" {
  project_id = zitadel_project.baas.id
  org_id     = local.ZITADEL_ORG_ID
  name       = "baas"

  redirect_uris             = ["http://localhost:5173/auth/callback"]
  post_logout_redirect_uris = ["http://localhost:5173"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE", "OIDC_GRANT_TYPE_REFRESH_TOKEN"]
  app_type                  = "OIDC_APP_TYPE_WEB"
  auth_method_type          = "OIDC_AUTH_METHOD_TYPE_BASIC"
  version                   = "OIDC_VERSION_1_0"
  access_token_type         = "OIDC_TOKEN_TYPE_BEARER"
  # dev_mode allows the non-HTTPS http://localhost redirect during development
  dev_mode = true
}

output "baas_oidc_client_id" {
  value     = zitadel_application_oidc.baas.client_id
  sensitive = true
}
output "baas_oidc_client_secret" {
  value     = zitadel_application_oidc.baas.client_secret
  sensitive = true
}
