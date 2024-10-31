locals {
  TEMPORAL_DOMAIN   =  "temporal.${local.CLUSTER_NAME}"
}
resource "rustack_dns_record" "temporal_dns_record" {
  count  = var.SERVERS_NUM
  dns_id = data.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${local.TEMPORAL_DOMAIN}."
  data   = resource.rustack_vm.cluster[count.index].floating_ip
}
resource "postgresql_role" "temporal" {
  depends_on = [ null_resource.step_postgresql ]
  name  = "temporal"
  login = true
  create_database = true
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
# resource "helm_release" "temporal" {
#   #count = 0
#   depends_on       = [null_resource.k3s_finalize]
#   repository       = "https://go.temporal.io/helm-charts"
#   name             = "temporal"
#   chart            = "temporal"
#   namespace        = kubernetes_namespace.temporal.metadata[0].name
#   #create_namespace = true
#   values = [
#     templatefile("charts/temporal-values.yaml.tpl", {
#       TEMPORAL_DOMAIN = "${local.TEMPORAL_DOMAIN}"
#       DEX_DOMAIN = var.DEX_DOMAIN
#       DB_HOST = "${terraform_data.postgresqlname[0].output}."
#       DB_NAME = postgresql_database.temporal.name
#       DB_VISIBILITY_NAME = postgresql_database.temporal_visibility.name
#     })
#   ]
#   set_sensitive {
#     name  = "web.additionalEnv[0].value"
#      value = var.TEMPORAL_STATIC_CLIENT_SECRET
#   }
# }

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
