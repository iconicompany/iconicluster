locals {
  TEMPORAL_DOMAIN = "temporal.${local.CLUSTER_NAME}"
}
resource "rustack_dns_record" "temporal_dns_record" {
  # Create DNS_NUM records for the TEMPORAL_DOMAIN, pointing to the
  # external IPs of the first DNS_NUM cluster nodes (or fewer if not enough nodes).
  # This allows for round-robin DNS if multiple records are created for the same host.
  for_each = {
    for i in range(min(var.DNS_NUM, length(local.nodes_output.CLUSTER_NODES))) :
    i => local.nodes_output.CLUSTER_NODES[i].external_ip
  }
  dns_id = data.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${local.TEMPORAL_DOMAIN}."
  data   = each.value # This is the external_ip from the for_each map
}
resource "postgresql_role" "temporal" {
  depends_on      = [null_resource.step_postgresql]
  name            = "temporal"
  login           = true
  create_database = true
  # password = var.TEMPORAL_DB_PASSWORD
}


resource "postgresql_database" "temporal" {
  name              = "temporal"
  owner             = postgresql_role.temporal.name
  lc_collate        = "C"
  connection_limit  = -1
  allow_connections = true
}


resource "postgresql_database" "temporal_visibility" {
  name              = "temporal_visibility"
  owner             = postgresql_role.temporal.name
  lc_collate        = "C"
  connection_limit  = -1
  allow_connections = true
}

resource "kubernetes_namespace" "temporal" {
  metadata {
    labels = {
      "autocert.step.sm" = "enabled"
    }

    name = "temporal"
  }
}
# resource "kubernetes_secret" "temporal" {
#   metadata {
#     name = "temporal-secret"
#     namespace        = kubernetes_namespace.temporal.metadata[0].name
#   }
#   data = {
#     password = var.TEMPORAL_DB_PASSWORD
#   }
# }
resource "helm_release" "temporal" {
  #count = 0
  depends_on = [null_resource.k3s_finalize]
  repository = "https://go.temporal.io/helm-charts"
  name       = "temporal"
  chart      = "temporal"
  namespace  = kubernetes_namespace.temporal.metadata[0].name
  #create_namespace = true
  values = [
    templatefile("charts/temporal-values.yaml.tpl", {
      TEMPORAL_DOMAIN    = "${local.TEMPORAL_DOMAIN}"
      DEX_DOMAIN         = var.DEX_DOMAIN
      DB_HOST            = "${terraform_data.postgresqlname[0].output}."
      DB_NAME            = postgresql_database.temporal.name
      DB_VISIBILITY_NAME = postgresql_database.temporal_visibility.name
    })
    # DB_SECRET_NAME = kubernetes_secret.temporal.metadata[0].name
  ]
  set_sensitive {
    name  = "web.additionalEnv[0].value"
    value = var.TEMPORAL_STATIC_CLIENT_SECRET
  }
}

resource "kubernetes_labels" "temporal" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = "temporal"
  }
  labels = {
    "autocert.step.sm" = "enabled"
  }
}
