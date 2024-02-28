module "k3s" {
  source = "xunleii/k3s/module"

  #depends_on_   = resource.rustack_vm.cluster 
  depends_on_    = null_resource.step_k3s_ca
  k3s_version    = "latest"
  cluster_domain = "cluster.${var.CLUSTER_DOMAIN}"
  cidr = {
    pods     = "10.42.0.0/16"
    services = "10.43.0.0/16"
  }
  drain_timeout            = "30s"
  generate_ca_certificates = false
  managed_fields           = ["label", "taint"] // ignore annotations
  use_sudo                 = true
  global_flags = [
    "--disable=traefik",
    "--secrets-encryption",
    "--tls-san ${var.CLUSTER_DOMAIN}"
  ]

  servers = {
    for i in range(length(rustack_vm.cluster)) :
    "node${i + 10}.${var.CLUSTER_DOMAIN}" => {
      ip = rustack_port.cluster_port[i].ip_address
      connection = {
        host = rustack_vm.cluster[i].floating_ip
        user = var.USER_LOGIN
      }
      flags = [
      ]
      annotations = { "server_id" : i } // theses annotations will not be managed by this module
    }
  }

}

resource "null_resource" "k3s_finalize" {
  depends_on = [module.k3s]
  connection {
    # line below not working when SERVERS_NUM=0
    host = rustack_vm.cluster[0].floating_ip
    #host      = var.CLUSTER_DOMAIN
    user = var.USER_LOGIN
  }

  provisioner "remote-exec" {
    inline = [
      "sudo kubectl create clusterrolebinding ${var.USER_LOGIN}-${var.CLUSTER_GRANT_ROLE}-binding --clusterrole=${var.CLUSTER_GRANT_ROLE} --user=${var.USER_LOGIN}"
    ]
  }

}
