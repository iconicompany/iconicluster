# ZITADEL project + OIDC app for a local Next.js (Auth.js / NextAuth) dev app.
# org_id is omitted on both resources -> the zitadel provider uses the org of the
# authenticated service account (the "terraform" service user, ORG_OWNER).

resource "zitadel_project" "nextjs" {
  name = "nextjs"
}

resource "zitadel_application_oidc" "nextjs" {
  project_id = zitadel_project.nextjs.id
  name       = "nextjs"

  redirect_uris             = ["http://localhost:3000/api/auth/callback/zitadel"]
  post_logout_redirect_uris = ["http://localhost:3000"]
  response_types            = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types               = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE", "OIDC_GRANT_TYPE_REFRESH_TOKEN"]
  app_type                  = "OIDC_APP_TYPE_WEB"
  # NextAuth/Auth.js uses a confidential client (client_id + client_secret)
  auth_method_type  = "OIDC_AUTH_METHOD_TYPE_BASIC"
  version           = "OIDC_VERSION_1_0"
  access_token_type = "OIDC_TOKEN_TYPE_BEARER"
  # required so ZITADEL accepts the non-HTTPS http://localhost redirect
  dev_mode = true
}

output "nextjs_client_id" {
  value     = zitadel_application_oidc.nextjs.client_id
  sensitive = true
}

output "nextjs_client_secret" {
  value     = zitadel_application_oidc.nextjs.client_secret
  sensitive = true
}
