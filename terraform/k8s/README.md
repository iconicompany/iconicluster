# terraform/k8s

Prod Kubernetes + ZITADEL infrastructure (Terraform). This doc covers **ZITADEL
credential management**: rotating the Terraform-managed secrets, and issuing new
per-app service logins.

## Prerequisites

- **Provider auth.** The `zitadel` provider authenticates with an IAM_OWNER
  service-account key at `~/.zitadel/terraform-key.json` (see `providers.tf` →
  `jwt_profile_file`). It must be present locally.
- **Proxy.** `HTTPS_PROXY` MITM breaks TLS to internal hosts. Send internal hosts
  direct, keep the proxy for the registry/rustack:
  ```bash
  cd terraform/k8s
  export no_proxy=".icncd.ru,.iconicompany.com,localhost,127.0.0.1"
  export NO_PROXY="$no_proxy"     # leave HTTPS_PROXY set for registry + rustack
  ```
- ⚠️ **These are live prod credentials** — consumers break until you push the new
  values. Always `terraform plan` first, and update `.env`/secrets right after.

---

## Rotate the Terraform-managed secrets (`-replace`)

`zitadel-app.tf` exposes two secrets as outputs (nothing is written to disk
automatically — read them with `terraform output`):

| Resource | Output(s) |
|---|---|
| `zitadel_machine_key.default` | `default_key` (SA JSON key) |
| `zitadel_application_oidc.default` | `default_oidc_client_id`, `default_oidc_client_secret` |

Rotation uses `terraform apply -replace=<addr>` (the modern `taint`).

### Service-account key — safe rotation

Rotates only the key; the machine user, its roles, and the OIDC `client_id` are
untouched.

```bash
terraform plan  -replace='zitadel_machine_key.default'   # review
terraform apply -replace='zitadel_machine_key.default'
terraform output -raw default_key                        # new JSON key
```

Update the consumer's `ZITADEL_SERVICE_ACCOUNT_KEY` with the new key.
`zitadel-flows ≥ 0.2` takes the JSON object/string directly (no base64); older
code expected base64 of the JSON.

### OIDC client secret — recreates the app

The `zitadel` provider has no "secret-only" regenerate; `client_secret` is
computed. `-replace` recreates the application, so you get a **new `client_id`
AND `client_secret`** (the `redirect_uris` live in config and are preserved):

```bash
terraform apply -replace='zitadel_application_oidc.default'
terraform output -raw default_oidc_client_id
terraform output -raw default_oidc_client_secret
```

Update **both** `client_id` and `client_secret` in every consumer.

> Regenerating *only* the secret while keeping `client_id` is possible only in
> the ZITADEL console (App → Regenerate Client Secret). But the new secret can't
> be read back via the API, so Terraform's `default_oidc_client_secret` output
> goes stale (state drift). For Terraform-managed apps, prefer `-replace`.

---

## Issue a NEW per-app service login (`create_zitadel_service_login.sh`)

Mints a **brand-new** ZITADEL service account (independent of the
Terraform-managed `default` one — it is **not** added to Terraform state),
grants it `IAM_LOGIN_CLIENT` + `ORG_USER_MANAGER`, and saves its key.

```bash
./create_zitadel_service_login.sh <service_name>
```

Writes (both gitignored):
- `.zitadel/<service_name>-key.json` — the JSON key
- appends to `./.env`: `ZITADEL_URL` and `ZITADEL_SERVICE_ACCOUNT_KEY` (base64 of the JSON key)

Optional env overrides:

| Var | Default |
|---|---|
| `ZITADEL_URL` | `https://zitadel.iconicompany.com` |
| `ZITADEL_ADMIN_KEY` | `~/.zitadel/terraform-key.json` (must be IAM_OWNER) |
| `ZITADEL_KEY_OUT` | `./.zitadel/<service>-key.json` (`""` to skip the file) |
| `ZITADEL_ENV_OUT` | `./.env` (`""` to skip) |
| `ZITADEL_RESOLVE_IP` | — (e.g. `212.22.94.191`; adds `curl --resolve` if DNS is flaky) |
| `ZITADEL_ORG_ROLES` | `ORG_USER_MANAGER` |
| `ZITADEL_IAM_ROLES` | `IAM_LOGIN_CLIENT` |

It mints an admin token from `ZITADEL_ADMIN_KEY` via JWT-profile, so the same
proxy note applies (or set `ZITADEL_RESOLVE_IP` to bypass DNS/proxy issues).

### Which one do I use?

- **Rotate** the existing `default` app's key/secret → Terraform `-replace` (above).
- **New, independent** service/app login → `create_zitadel_service_login.sh`.
