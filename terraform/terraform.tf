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
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
  }
}

provider "rustack" {
  api_endpoint = var.RUSTACK_ENDPOINT
  token        = var.RUSTACK_TOKEN
}
provider "kubectl" {
  host                   = "${var.CLUSTER_DOMAIN}:6443"
  cluster_ca_certificate = file(pathexpand(var.CLUSTER_CA_CERTIFICATE))
  client_certificate     = file(pathexpand(var.CLIENT_CERTIFICATE))
  client_key             = file(pathexpand(var.CLIENT_KEY))
  load_config_file       = false
}
provider "helm" {
  kubernetes {
    host                   = "${var.CLUSTER_DOMAIN}:6443"
    cluster_ca_certificate = file(pathexpand(var.CLUSTER_CA_CERTIFICATE))
    client_certificate     = file(pathexpand(var.CLIENT_CERTIFICATE))
    client_key             = file(pathexpand(var.CLIENT_KEY))
  }
}
provider "kubernetes" {
  host                   = "${var.CLUSTER_DOMAIN}:6443"
  cluster_ca_certificate = file(pathexpand(var.CLUSTER_CA_CERTIFICATE))
  client_certificate     = file(pathexpand(var.CLIENT_CERTIFICATE))
  client_key             = file(pathexpand(var.CLIENT_KEY))
}


provider "postgresql" {
  host        = var.POSTGRESQL_HOST
  port        = var.K3S_DB_PORT
  database    = "postgres"
  username    = var.USER_LOGIN
  sslmode     = "verify-full"
  sslrootcert = pathexpand(var.CLUSTER_CA_CERTIFICATE)
  clientcert {
    cert = pathexpand(var.CLIENT_CERTIFICATE)
    key  = pathexpand(var.CLIENT_KEY)
  }
}
