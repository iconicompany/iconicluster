resource "helm_release" "dex" {
  name             = "dex"
  repository       = "https://charts.dexidp.io"
  chart            = "dex"
  namespace        = "dex"
  create_namespace = true

  values = [
    templatefile("charts/dex-values.yaml.tpl", {
      DEX_DOMAIN                = var.DEX_DOMAIN
      TEMPORAL_DOMAIN = "${local.TEMPORAL_HOST}"
      OUTLINE_DOMAIN = var.OUTLINE_DOMAIN
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
  set_sensitive {
    name  = "config.staticClients[1].secret"
    value = var.TEMPORAL_STATIC_CLIENT_SECRET
  }
   set_sensitive {
    name  = "config.staticClients[2].secret"
    value = var.OUTLINE_CLIENT_SECRET
  }
}
