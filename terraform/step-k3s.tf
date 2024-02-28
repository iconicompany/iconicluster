locals {
  certificates_names = var.SERVERS_NUM > 0 ? ["client-ca", "server-ca", "request-header-ca", "etcd/peer-ca", "etcd/server-ca"] : []
  certificates_types = { for s in local.certificates_names : index(local.certificates_names, s) => s }
  source_ca_path     = "${var.STEPCERTPATH}/k3s"
  target_ca_path     = "/var/lib/rancher/k3s/server/tls"
}

# tokens for CA
data "external" "step_k3s_ca_token" {
  for_each = local.certificates_types
  program  = ["bash", "${path.module}/step-ca-token.sh"]

  query = {
    STEPPATH           = var.STEPPATH
    STEP_PROVISIONER   = var.STEP_PROVISIONER_KUBE
    STEP_PASSWORD_FILE = var.STEP_PASSWORD_KUBE
    CN                 = replace(each.value, "/", "-")
  }
}

# generate CA
resource "null_resource" "step_k3s_ca" {
  depends_on = [null_resource.step_cli_install]

  for_each = local.certificates_types
  connection {
    #host     = resource.terraform_data.hostname[0].output
    # line below not working when SERVERS_NUM=0
    host = rustack_vm.cluster[0].floating_ip
    #host      = var.CLUSTER_DOMAIN
    user = var.USER_LOGIN
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p ${local.source_ca_path}/$(dirname ${each.value}) ${local.target_ca_path}/$(dirname ${each.value})",
      "sudo env STEP_TOKEN=${data.external.step_k3s_ca_token[each.key].result.TOKEN} step ca certificate ${replace(each.value, "/", "-")} ${local.source_ca_path}/${each.value}.crt ${local.source_ca_path}/${each.value}.key --provisioner ${var.STEP_PROVISIONER_KUBE}",
      "sudo cp ${local.source_ca_path}/${each.value}.crt ${local.target_ca_path}/${each.value}.crt",
      "sudo cp ${local.source_ca_path}/${each.value}.key ${local.target_ca_path}/${each.value}.key"
    ]
  }

}
