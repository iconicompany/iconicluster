locals {
  TEMPORAL_HOST   =  "temporal.${local.CLUSTER_NAME}"
}
resource "rustack_dns_record" "temporal_dns_record" {
  count  = var.SERVERS_NUM
  dns_id = resource.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${local.TEMPORAL_HOST}."
  data   = resource.rustack_vm.cluster[count.index].floating_ip
}
resource "postgresql_role" "temporal" {
  depends_on = [ null_resource.step_postgresql ]
  name  = "temporal"
  login = true
  create_database = true
}

resource "kubernetes_namespace" "temporal" {
  metadata {
    labels = {
      "autocert.step.sm" = "enabled"
    }

    name = "temporal"
  }
}
resource "helm_release" "temporal" {
  #count = 0
  depends_on       = [null_resource.k3s_finalize]
  repository       = "https://go.temporal.io/helm-charts"
  name             = "temporal"
  chart            = "temporal"
  namespace        = kubernetes_namespace.temporal.metadata[0].name
  #create_namespace = true

  values = [
    templatefile("charts/temporal-values.yaml.tpl", {
      DOMAIN = "${local.TEMPORAL_HOST}"
      DB_HOST = "${terraform_data.postgresqlname[0].output}."
    })
  ]
  set {
     name  = "server.replicaCount"
     value = "1"
  }
  set {
     name  = "cassandra.config.cluster_size"
     value = "1"
  }
  set {
     name  = "elasticsearch.replicas"
     value = "1"
  }
  #set {
  #   name  = "prometheus.enabled"
  #   value = "false"
  #}
  #set {
  #   name  = "temporal.enabled"
  #   value = "false"
  #}
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
