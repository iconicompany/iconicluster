resource "kubernetes_namespace" "dex" {
  metadata {
    labels = {
      "autocert.step.sm" = "enabled"
    }

    name = "dex"
  }
}
resource "helm_release" "dex" {
  name             = "dex"
  repository       = "https://charts.dexidp.io"
  chart            = "dex"
  namespace        = kubernetes_namespace.dex.metadata[0].name
  depends_on = [ postgresql_database.dex ]
  #create_namespace = true

  values = [
    templatefile("charts/dex-values.yaml.tpl", {
      DEX_DOMAIN      = var.DEX_DOMAIN
      DB_HOST         = terraform_data.postgresqlname[0].output
      DB_NAME         = postgresql_database.dex.name
      DB_USER         = postgresql_role.dex.name
      TEMPORAL_DOMAIN = "${local.TEMPORAL_DOMAIN}"
      OUTLINE_DOMAIN  = var.OUTLINE_DOMAIN
      # GITHUB_CLIENT_ID     = var.GITHUB_CLIENT_ID
      # GITHUB_CLIENT_SECRET = var.GITHUB_CLIENT_SECRET
    })
  ]
  set_sensitive {
    name  = "config.staticClients[0].secret"
    value = var.STEP_STATIC_CLIENT_SECRET
  }

  set_sensitive {
    name  = "config.connectors[0].config.clientID"
    value = var.GITHUB_CLIENT_ID
  }
  set_sensitive {
    name  = "config.connectors[0].config.clientSecret"
    value = var.GITHUB_CLIENT_SECRET
  }
#  set_sensitive {
#    name  = "config.connectors[1].config.clientID"
#    value = var.HH_CLIENT_ID
#  }
#  set_sensitive {
#    name  = "config.connectors[1].config.clientSecret"
#    value = var.HH_CLIENT_SECRET
#  }

  set_sensitive {
    name  = "config.staticClients[1].secret"
    value = var.TEMPORAL_STATIC_CLIENT_SECRET
  }
  set_sensitive {
    name  = "config.staticClients[2].secret"
    value = var.OUTLINE_CLIENT_SECRET
  }
  set_sensitive {
    name  = "config.staticClients[3].secret"
    value = var.IMARKETPLACE_CLIENT_SECRET
  }

}

resource "postgresql_role" "dex" {
  depends_on = [null_resource.step_postgresql]
  name       = "dex"
  login      = true
}

resource "postgresql_database" "dex" {
  name              = "dex"
  owner             = postgresql_role.dex.name
  lc_collate        = "C"
  connection_limit  = -1
  allow_connections = true
}
