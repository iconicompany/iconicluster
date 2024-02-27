module "nginx-controller" {
  depends_on = [module.k3s]
  source     = "terraform-iaac/nginx-controller/helm"
}
module "cert_manager" {
  depends_on = [ module.nginx-controller ]
  source        = "terraform-iaac/cert-manager/kubernetes"

  cluster_issuer_email                   = var.CLUSTER_ISSUER_EMAIL
  cluster_issuer_name                    = "letsencrypt-prod"
  cluster_issuer_private_key_secret_name = "letsencrypt-prod"
}


