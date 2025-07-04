module "nginx-controller" {
  # depends_on = [null_resource.k3s_finalize]
  source     = "terraform-iaac/nginx-controller/helm"
}
module "cert_manager" {
  depends_on = [module.nginx-controller]
  source     = "terraform-iaac/cert-manager/kubernetes"
  #chart_version                          = "1.14.3"
  cluster_issuer_email                   = var.CLUSTER_ISSUER_EMAIL
  cluster_issuer_name                    = "letsencrypt-prod"
  cluster_issuer_private_key_secret_name = "letsencrypt-prod"
}

# resource "kubernetes_config_map" "root_ca" {
#   metadata {
#     name = "root-ca"
#   }

#   data = {
#     "root_ca.crt" = "${file(var.STEP_ROOT_CA_PATH)}"
#   }

# }

resource "helm_release" "smallstep-autocert" {
  #count = 0
  # depends_on       = [null_resource.k3s_finalize]
  repository       = "https://smallstep.github.io/helm-charts"
  name             = "autocert"
  chart            = "autocert"
  namespace        = "smallstep"
  create_namespace = true
  values = [
    templatefile("charts/autocert-values.yaml.tpl", {
      STEP_CA_URL      = var.STEP_CA_URL
      STEP_PROVISIONER = var.STEP_PROVISIONER_AUTOCERT
      # STEP_PASSWORD    = file(var.STEP_PASSWORD_FILE)
      STEP_ROOT_CA = indent(6, file(var.STEP_ROOT_CA_PATH))
    })
  ]
  # set {
  #   name  = "step-certificates.enabled"
  #   value = "false"
  # }
  #   set {
  #     name  = "ca.url"
  #     value = var.STEP_CA_URL
  #   }
  #   set {
  #     name  = "ca.provisioner.name"
  #     value = var.STEP_PROVISIONER_AUTOCERT
  #   }
  set_sensitive {
    name  = "ca.provisioner.password"
    value = file(var.STEP_PASSWORD_AUTOCERT)
  }
  #  set {
  #    name  = "ca.certs"
  #    value = "\\{\"root_ca.crt\": \"${file(var.STEP_ROOT_CA_PATH)}\"\\}"
  #  }
  #   set {
  #     name  = "ca.config.defaults.json"
  #     value = "{}"
  #   }
}


#resource "rustack_dns_record" "pgadmin4_dns_record" {
#  count  = var.DNS_NUM
#  dns_id = data.rustack_dns.cluster_dns.id
#  type   = "CNAME"
#  host   = "pgadmin4.${var.CLUSTER_DOMAIN}."
#  data   = "${var.CLUSTER_DOMAIN}."
#}

# resource "kubernetes_namespace" "pgadmin4" {
#   metadata {
#     labels = {
#       "autocert.step.sm" = "enabled"
#     }

#     name = "pgadmin4"
#   }
# }

#resource "helm_release" "pgadmin4" {
#  name             = "pgadmin4"
#  repository       = "https://helm.runix.net"
#  chart            = "pgadmin4"
#  namespace        = "pgadmin4"
#  create_namespace = true
#
#  values = [
#    templatefile("charts/pgadmin4-values.yaml.tpl", {
#      DOMAIN = "pgadmin4.${var.CLUSTER_DOMAIN}"
#    })
#  ]
#  set_sensitive {
#    name  = "env.email"
#    value = var.PGADMIN4_EMAIL
#  }
#  set_sensitive {
#    name  = "env.password"
#    value = var.PGADMIN4_PASSWORD
#  }
#}
#resource "kubernetes_labels" "pgadmin4" {
#  api_version = "v1"
#  kind        = "Namespace"
#  metadata {
#    name = "pgadmin4"
#  }
#  labels = {
#    "autocert.step.sm" = "enabled"
#  }
#}
