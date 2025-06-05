locals {
  CLUSTER_DOMAIN = "cluster.local"
}

module "k3s" {
  source = "github.com/iconicompany/terraform-module-k3s"

  #depends_on_   = resource.rustack_vm.cluster 
  depends_on_    = null_resource.step_k3s_ca
  k3s_version    = "latest"
  cluster_domain = local.CLUSTER_DOMAIN
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
    for i in range(var.SERVERS_NUM) :
    i => {
      ip = module.nodes.cluster_internal_ips[i]
      name = module.nodes.cluster_vm_names[i]
      connection = {
        host = module.nodes.cluster_floating_ips[i]
        user = var.USER_LOGIN
      }
      flags = [
        "--disable=traefik",
        "--secrets-encryption",
        "--tls-san ${local.CLUSTER_NAME}",
        "--datastore-endpoint=\"postgres://${var.K3S_DB_USER}@${var.POSTGRESQL_HOST}:${var.K3S_DB_PORT}/${postgresql_database.k3s.name}\"",
        "--datastore-cafile=\"${pathexpand(var.CLUSTER_CA_CERTIFICATE)}\"",
        "--datastore-certfile=\"${var.STEPCERTPATH}/k3s.crt\"",
        "--datastore-keyfile=\"${var.STEPCERTPATH}/k3s.key\""
      ]
      annotations = { "server_id" : i } // theses annotations will not be managed by this module
    }
  }
  agents = {
    for i in range(var.AGENTS_NUM) :
    i => {
      ip = module.nodes.agent_internal_ips[i]    # Assuming agent_port is part of the new module
      name = module.nodes.agent_vm_names[i]      # Assuming agent VM is part of the new module
      connection = {
        host = module.nodes.agent_floating_ips[i] # Assuming agent VM is part of the new module
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
  depends_on = [ null_resource.step_postgresql ]
  name  = "k3s"
  login = true
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
    host = module.nodes.cluster_floating_ips[0]
    user = var.USER_LOGIN
  }

  provisioner "remote-exec" {
    inline = [
      "sudo kubectl create clusterrolebinding ${var.USER_LOGIN}-${var.CLUSTER_GRANT_ROLE}-binding --clusterrole=${var.CLUSTER_GRANT_ROLE} --user=${var.USER_LOGIN}"
    ]
  }

}

resource "local_file" "registries_yaml" {
  content  = templatefile("${path.module}/registries.yaml.tpl", {
    CONTAINER_MIRROR          = var.CONTAINER_MIRROR
    CONTAINER_REGISTRY        = var.CONTAINER_REGISTRY
    CONTAINER_REGISTRY_USERNAME = var.CONTAINER_REGISTRY_USERNAME
    CONTAINER_REGISTRY_PASSWORD = var.CONTAINER_REGISTRY_PASSWORD
  })
  filename = "${path.module}/registries.yaml"
}

resource "null_resource" "configure_node_registry" {
  count  = var.SERVERS_NUM
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host = module.nodes.cluster_floating_ips[count.index]
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
  count  = var.AGENTS_NUM
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host = module.nodes.agent_floating_ips[count.index]
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
