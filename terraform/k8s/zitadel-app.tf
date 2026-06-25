# Drives headless auth via the ZITADEL API: register users, email-code login
# (Session API), and finalizing OIDC auth requests. Each app gets its own account.
resource "zitadel_machine_user" "default" {
  org_id      = local.ZITADEL_ORG_ID
  user_name   = "default"
  name        = "default service account"
  description = "Backend service account for the default app (headless auth)"
}

resource "zitadel_machine_key" "default" {
  org_id   = local.ZITADEL_ORG_ID
  user_id  = zitadel_machine_user.default.id
  key_type = "KEY_TYPE_JSON"
}

# IAM_LOGIN_CLIENT: required for the Session API and finalizing OIDC auth requests.
resource "zitadel_instance_member" "default_login_client" {
  user_id = zitadel_machine_user.default.id
  roles   = ["IAM_LOGIN_CLIENT"]
}

# ORG_USER_MANAGER: create/verify users (registration, email verification, OTP email).
resource "zitadel_org_member" "default_user_manager" {
  org_id  = local.ZITADEL_ORG_ID
  user_id = zitadel_machine_user.default.id
  roles   = ["ORG_USER_MANAGER"]
}

# JSON service-account key (jwt-profile) for the default app. Sensitive; written to the
# default project's gitignored .zitadel/default-key.json, not committed here.
output "default_key" {
  value     = zitadel_machine_key.default.key_details
  sensitive = true
}

# OIDC client for the default gateway (variant 4B: real ZITADEL tokens). The service
# account drives login via the Session API and finalizes auth requests for THIS client.
resource "zitadel_project" "default" {
  name   = "default"
  org_id = local.ZITADEL_ORG_ID
}

resource "zitadel_application_oidc" "default" {
  project_id = zitadel_project.default.id
  org_id     = local.ZITADEL_ORG_ID
  name       = "default"

  redirect_uris             = ["http://localhost:5173/auth/callback"]
  post_logout_redirect_uris = ["http://localhost:5173"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE", "OIDC_GRANT_TYPE_REFRESH_TOKEN"]
  app_type                  = "OIDC_APP_TYPE_WEB"
  auth_method_type          = "OIDC_AUTH_METHOD_TYPE_BASIC"
  version = "OIDC_VERSION_1_0"
  # JWT access tokens so the gateway can verify them locally (JWKS) without introspection.
  access_token_type = "OIDC_TOKEN_TYPE_JWT"
  # dev_mode allows the non-HTTPS http://localhost redirect during development
  dev_mode = true
}

output "default_oidc_client_id" {
  value     = zitadel_application_oidc.default.client_id
  sensitive = true
}
output "default_oidc_client_secret" {
  value     = zitadel_application_oidc.default.client_secret
  sensitive = true
}
