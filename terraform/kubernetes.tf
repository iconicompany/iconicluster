module "nginx-controller" {
  depends_on = [null_resource.k3s_finalize]
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

