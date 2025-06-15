locals {
  CLUSTER_LOCAL_DOMAIN = "cluster.local"
}

module "k3s" {
  source = "github.com/iconicompany/terraform-module-k3s"

  #depends_on_   = resource.rustack_vm.cluster 
  depends_on_    = null_resource.step_k3s_ca
  k3s_version    = "latest"
  cluster_domain = local.CLUSTER_LOCAL_DOMAIN
  cidr = {
    pods     = "10.42.0.0/16"
    services = "10.43.0.0/16"
  }
  drain_timeout            = "60s"
  generate_ca_certificates = false
  managed_fields           = ["label", "taint"] // ignore annotations
  use_sudo                 = true
  global_flags = [
  ]

  servers = {
    for i, node in local.nodes_output.SERVER_NODES :
    i => { # Using index i as key for compatibility if needed, or node.vm_name
      ip   = node.internal_ip
      name = node.vm_name # or node.hostname
      connection = {
        host = node.hostname
        user = var.USER_LOGIN
      }
      flags = [
        "--disable=traefik",
        "--secrets-encryption",
        "--tls-san ${var.CLUSTER_DOMAIN}",
        "--datastore-endpoint=\"postgres://${var.K3S_DB_USER}@${var.POSTGRESQL_HOST}:${var.K3S_DB_PORT}/${postgresql_database.k3s.name}\"",
        "--datastore-cafile=\"${pathexpand(var.CLUSTER_CA_CERTIFICATE)}\"",
        "--datastore-certfile=\"${var.STEPCERTPATH}/k3s.crt\"",
        "--datastore-keyfile=\"${var.STEPCERTPATH}/k3s.key\""
      ]
      annotations = { "server_id" : i } // theses annotations will not be managed by this module
    }
  }
  agents = {
    for i, node in local.nodes_output.AGENT_NODES :
    i => { # Using index i as key
      ip   = node.internal_ip
      name = node.vm_name # or node.hostname
      connection = {
        host = node.hostname
        user = var.USER_LOGIN
      }
      #flags = [
      #  "--datastore-endpoint=\"postgres://${var.K3S_DB_USER}@${var.POSTGRESQL_HOST}:${var.K3S_DB_PORT}/${postgresql_database.k3s.name}\"",
      #  "--datastore-cafile=\"${pathexpand(var.CLUSTER_CA_CERTIFICATE)}\"",
      #  "--datastore-certfile=\"${var.STEPCERTPATH}/k3s.crt\"",
      #  "--datastore-keyfile=\"${var.STEPCERTPATH}/k3s.key\""
      #]
      # labels = { "node.kubernetes.io/pool" = hcloud_server.agents[i].labels.nodepool }
      # taints = { "dedicated" : hcloud_server.agents[i].labels.nodepool == "gpu" ? "gpu:NoSchedule" : null }
    }
  }

}
resource "postgresql_role" "k3s" {
  depends_on = [null_resource.step_postgresql]
  name       = "k3s"
  login      = true
}

resource "postgresql_database" "k3s" {
  name              = var.K3S_DB_NAME
  owner             = postgresql_role.k3s.name
  lc_collate        = "C"
  connection_limit  = -1
  allow_connections = true
}

resource "null_resource" "k3s_finalize" {
  depends_on = [module.k3s]
  connection {
    host = local.nodes_output.SERVER_NODES[0].hostname
    user = var.USER_LOGIN
  }

  provisioner "remote-exec" {
    inline = [
      "sudo kubectl create clusterrolebinding ${var.USER_LOGIN}-${var.CLUSTER_GRANT_ROLE}-binding --clusterrole=${var.CLUSTER_GRANT_ROLE} --user=${var.USER_LOGIN}"
    ]
  }

}

resource "local_file" "registries_yaml" {
  content = templatefile("${path.module}/registries.yaml.tpl", {
    CONTAINER_MIRROR            = var.CONTAINER_MIRROR
    CONTAINER_REGISTRY          = var.CONTAINER_REGISTRY
    CONTAINER_REGISTRY_USERNAME = var.CONTAINER_REGISTRY_USERNAME
    CONTAINER_REGISTRY_PASSWORD = var.CONTAINER_REGISTRY_PASSWORD
  })
  filename = "${path.module}/registries.yaml"
}

resource "null_resource" "configure_node_registry" {
  for_each = { for idx, node in local.nodes_output.SERVER_NODES : idx => node }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = each.value.hostname
      user = var.USER_LOGIN
    }

    on_failure = fail
    inline = [
      "set -o errexit",
      "sudo mkdir -p /etc/rancher/k3s",
      "cat <<EOF |sudo tee /etc/rancher/k3s/registries.yaml",
      "${local_file.registries_yaml.content}",
      "EOF",
      "sudo chmod 600 /etc/rancher/k3s/registries.yaml",
    ]
  }
}

resource "null_resource" "configure_agent_registry" {
  for_each = { for idx, node in local.nodes_output.AGENT_NODES : idx => node }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = each.value.hostname
      user = var.USER_LOGIN
    }
    on_failure = fail
    inline = [
      "set -o errexit",
      "sudo mkdir -p /etc/rancher/k3s",
      "cat <<EOF |sudo tee /etc/rancher/k3s/registries.yaml",
      "${local_file.registries_yaml.content}",
      "EOF",
      "sudo chmod 600 /etc/rancher/k3s/registries.yaml",
    ]
  }
}
