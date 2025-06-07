# Инициализация Terraform и конфигурации провайдера (шаг 1)
terraform {
  backend "s3" {}

  required_version = ">= 1.0.0"

  required_providers {
    rustack = {
      source  = "pilat/rustack"
      version = "> 1.1.0"
    }
  }
}


provider "rustack" {
  api_endpoint = var.RUSTACK_ENDPOINT
  token        = var.RUSTACK_TOKEN
}
