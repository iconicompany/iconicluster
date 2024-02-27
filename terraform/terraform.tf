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

# Получение параметров созданного автоматически проекта по его имени (шаг 2)
data "rustack_project" "iconicproject" {
  name = "Мой проект"
}

