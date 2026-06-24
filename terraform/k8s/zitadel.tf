locals {
  # External domain for ZITADEL. DNS for *.iconicompany.com is managed outside
  # this terraform state (same as dex.iconicompany.com), so no rustack_dns_record
  # here — the A/CNAME for this host must point at the nginx ingress.
  ZITADEL_DOMAIN = "zitadel.iconicompany.com"
}

# 32-byte ZITADEL master encryption key (alphanumeric => exactly 32 bytes).
resource "random_password" "zitadel_masterkey" {
  length  = 32
  special = false
}

# PostgreSQL password for the zitadel role (scram-sha-256 auth over TLS).
resource "random_password" "zitadel_db" {
  length  = 24
  special = false
}

resource "postgresql_role" "zitadel" {
  name     = "zitadel"
  login    = true
  password = random_password.zitadel_db.result
  # ZITADEL's init job runs as Admin == this role; the db is pre-created below and
  # owned by it. create_database keeps `zitadel init database` idempotent.
  create_database = true
}

resource "postgresql_database" "zitadel" {
  name              = "zitadel"
  owner             = postgresql_role.zitadel.name
  lc_collate        = "C"
  connection_limit  = -1
  allow_connections = true
}

resource "kubernetes_namespace" "zitadel" {
  metadata {
    name = "zitadel"
  }
}

# masterkey delivered via existing secret (zitadel.masterkeySecretName).
resource "kubernetes_secret" "zitadel_masterkey" {
  metadata {
    name      = "zitadel-masterkey"
    namespace = kubernetes_namespace.zitadel.metadata[0].name
  }
  data = {
    masterkey = random_password.zitadel_masterkey.result
  }
}

resource "helm_release" "zitadel" {
  name       = "zitadel"
  repository = "https://charts.zitadel.com"
  chart      = "zitadel"
  version    = "10.0.4"
  namespace  = kubernetes_namespace.zitadel.metadata[0].name
  depends_on = [postgresql_database.zitadel, kubernetes_secret.zitadel_masterkey]
  # init + setup jobs + deployment/login readiness can exceed the 300s default
  timeout = 600

  values = [
    templatefile("charts/zitadel-values.yaml.tpl", {
      ZITADEL_DOMAIN   = local.ZITADEL_DOMAIN
      MASTERKEY_SECRET = kubernetes_secret.zitadel_masterkey.metadata[0].name
      # trailing dot => absolute FQDN, avoids the pod search-domain (cluster.local) suffix
      DB_HOST    = "${var.POSTGRESQL_HOST}."
      DB_NAME    = postgresql_database.zitadel.name
      DB_USER    = postgresql_role.zitadel.name
      TLS_SECRET = local.ZITADEL_DOMAIN
    })
  ]

  # Same password for runtime user and init admin (both are the zitadel role).
  set_sensitive {
    name  = "zitadel.secretConfig.Database.Postgres.User.Password"
    value = random_password.zitadel_db.result
  }
  set_sensitive {
    name  = "zitadel.secretConfig.Database.Postgres.Admin.Password"
    value = random_password.zitadel_db.result
  }
}
