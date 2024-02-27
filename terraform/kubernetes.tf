provider "kubectl" {
  host                   = "${var.CLUSTER_DOMAIN}:6443"
  cluster_ca_certificate = file("${var.STEPPATH}/certs/root_ca.crt")
  client_certificate     = file(pathexpand("~/.step/certs/my.crt"))
  client_key             = file(pathexpand("~/.step/certs/my.key"))
  load_config_file       = false
}
provider "helm" {
  kubernetes {
    host                   = "${var.CLUSTER_DOMAIN}:6443"
    cluster_ca_certificate = file("${var.STEPPATH}/certs/root_ca.crt")
    client_certificate     = file(pathexpand("~/.step/certs/my.crt"))
    client_key             = file(pathexpand("~/.step/certs/my.key"))
  }
}
provider "kubernetes" {
  host                   = "${var.CLUSTER_DOMAIN}:6443"
  cluster_ca_certificate = file(pathexpand(var.CLUSTER_CA_CERTIFICATE))
  client_certificate     = file(pathexpand(var.CLIENT_CERTIFICATE))
  client_key             = file(pathexpand(var.CLIENT_KEY))
}

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


