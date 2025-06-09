data "terraform_remote_state" "nodes" {
  backend = "s3" 

  config = {
    bucket = "terraform-testing"
    key    = "nodes/terraform.tfstate" # путь к tfstate-файлу
    region = "ru-central-1"              # если S3
  }
}

locals {
  CLUSTER_NAME = "${var.CLUSTER_NAME}.${var.CLUSTER_TLD}"
  nodes_output = data.terraform_remote_state.nodes.outputs.nodes
}
