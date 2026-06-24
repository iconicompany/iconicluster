# ZITADEL Helm chart values — chart 10.0.4 / appVersion v4
# Ref: https://github.com/zitadel/zitadel-charts/blob/main/charts/zitadel/values.yaml
# Example followed: examples/2-postgres-secure (split configmapConfig/secretConfig).
# DB auth is password (scram-sha-256) over TLS — see pg_hba rule for 10.42.0.0/16.
replicaCount: 1

zitadel:
  # masterkey is provided via an existing secret (kubernetes_secret.zitadel_masterkey)
  masterkeySecretName: ${MASTERKEY_SECRET}

  configmapConfig:
    ExternalDomain: ${ZITADEL_DOMAIN}
    ExternalPort: 443
    ExternalSecure: true
    TLS:
      # TLS is terminated at the nginx ingress, ZITADEL serves h2c internally
      Enabled: false
    Database:
      Postgres:
        Host: ${DB_HOST}
        Port: 5432
        Database: ${DB_NAME}
        MaxOpenConns: 20
        MaxIdleConns: 10
        MaxConnLifetime: 30m
        MaxConnIdleTime: 5m
        # The role + database are pre-created by terraform; Admin == User == zitadel.
        # SSL Mode "require" satisfies the server's hostssl rule without needing the
        # step-ca root mounted (no hostname/CA verification). Can be hardened to
        # verify-full later via zitadel.dbSslCaCrtSecret.
        User:
          Username: ${DB_USER}
          SSL:
            Mode: require
        Admin:
          Username: ${DB_USER}
          SSL:
            Mode: require
  # secretConfig.Database.Postgres.{User,Admin}.Password are injected via
  # helm set_sensitive in zitadel.tf, so no secrets live in this template.

# Main ZITADEL service (API, console, OIDC/SAML) — h2c backend.
ingress:
  enabled: true
  # "nginx" makes the chart add nginx.ingress.kubernetes.io/backend-protocol for h2c/gRPC
  controller: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: ${ZITADEL_DOMAIN}
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - ${ZITADEL_DOMAIN}
      secretName: ${TLS_SECRET}

# Login UI v2 — separate deployment, same host, path /ui/v2/login.
# cert-manager annotation lives on the main ingress only (it owns the cert);
# this ingress just reuses the same TLS secret so nginx serves it on the host.
login:
  enabled: true
  replicaCount: 1
  ingress:
    enabled: true
    controller: nginx
    hosts:
      - host: ${ZITADEL_DOMAIN}
        paths:
          - path: /ui/v2/login
            pathType: Prefix
    tls:
      - hosts:
          - ${ZITADEL_DOMAIN}
        secretName: ${TLS_SECRET}

# Use the external postgresql01 cluster DB, not the bundled Bitnami subchart.
postgresql:
  enabled: false
