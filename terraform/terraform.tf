# Инициализация Terraform и конфигурации провайдера (шаг 1)
terraform {
  backend "pg" {
    conn_str = "postgres://postgresql01.jupiter.icncd.ru/iconicluster"
  }

  required_version = ">= 1.0.0"

  required_providers {
    rustack = {
      source  = "pilat/rustack"
      version = "> 1.1.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.0.1"
    }

  }
}

provider "rustack" {
  api_endpoint = var.rustack_endpoint
  token        = var.rustack_token
}
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


