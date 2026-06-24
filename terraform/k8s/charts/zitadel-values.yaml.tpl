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
    # Behind nginx with a gRPC backend, the :authority becomes the internal upstream
    # name ("upstream_balancer"), so ZITADEL would build the console API URL as
    # https://upstream_balancer and the console fails with "Failed to fetch". Read the
    # real host from X-Forwarded-Host (set by nginx). The x-zitadel-* headers stay first
    # so the login v2 service (which sets x-zitadel-public-host) keeps working.
    InstanceHostHeaders:
      - "x-zitadel-instance-host"
      - "x-forwarded-host"
    PublicHostHeaders:
      - "x-zitadel-public-host"
      - "x-forwarded-host"
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
  # HTTP backend-protocol (default): nginx proxy_pass preserves Host=$best_http_host, so
  # ZITADEL builds the console api URL from the real host. With "nginx"/GRPC, grpc_pass
  # rewrites :authority to the internal upstream name ("upstream_balancer") and the console
  # fails with "Failed to fetch". ZITADEL's gRPC-web/Connect API works fine over HTTP/1.1.
  controller: generic
  # Set explicitly (like dex): the default IngressClass is only auto-assigned on create,
  # so a helm upgrade with an empty className drops the class and the controller stops
  # serving the ingress (404).
  className: nginx
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
    controller: generic
    className: nginx
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
