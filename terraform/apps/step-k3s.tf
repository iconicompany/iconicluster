locals {
  # Define certificate names only if there are cluster nodes to operate on
  certificates_names = length(local.nodes_output.CLUSTER_NODES) > 0 ? ["client-ca", "server-ca", "request-header-ca", "etcd/peer-ca", "etcd/server-ca"] : []
  certificates_types = { for s in local.certificates_names : index(local.certificates_names, s) => s }
  source_ca_path     = "${var.STEPCERTPATH}/k3s/tls"
  target_ca_path     = "/var/lib/rancher/k3s/server/tls"
}

# generate token for DB client certificate
data "external" "step_k3s_token" {
  # Create a token for each actual cluster node
  for_each = { for idx, node in local.nodes_output.CLUSTER_NODES : idx => node }
  program = ["bash", "${path.module}/step-ca-token.sh"]

  query = {
    STEPPATH           = var.STEPPATH
    STEP_PROVISIONER   = var.STEP_PROVISIONER
    STEP_PASSWORD_FILE = var.STEP_PASSWORD_FILE
    CN                 = "k3s"
  }
}

# generate DB client certificate
resource "null_resource" "step_k3s_cert" {
  # Create a certificate for each actual cluster node
  for_each   = { for idx, node in local.nodes_output.CLUSTER_NODES : idx => node }
  depends_on = [null_resource.step_cli]
  triggers = {
    vm_id = each.value.vm_id
  }
  connection {
    host = each.value.hostname
    user = var.USER_LOGIN
  }

  provisioner "remote-exec" {
    on_failure = fail
    inline = [
      "set -o errexit",
      "sudo mkdir -p ${var.STEPCERTPATH}",
      "sudo env STEP_TOKEN=${data.external.step_k3s_token[each.key].result.TOKEN} step ca certificate k3s ${var.STEPCERTPATH}/k3s.crt ${var.STEPCERTPATH}/k3s.key -f --provisioner ${var.STEP_PROVISIONER}",
      "sudo systemctl enable --now cert-renewer@k3s.timer"
    ]
  }

}


# tokens for CA
data "external" "step_k3s_ca_token" {
  # This resource depends on local.certificates_types, which itself depends on
  # whether there are any cluster nodes. If no nodes, local.certificates_types is empty.
  for_each = local.certificates_types
  program  = ["bash", "${path.module}/step-ca-token.sh"]

  query = {
    STEPPATH           = var.STEPPATH
    STEP_PROVISIONER   = var.STEP_PROVISIONER_KUBE_CA
    STEP_PASSWORD_FILE = var.STEP_PASSWORD_KUBE_CA
    CN                 = replace(each.value, "/", "-")
  }
}

# generate CA
resource "null_resource" "step_k3s_ca" {
  # This resource runs on the first cluster node for each certificate type.

  depends_on = [null_resource.step_cli]
  triggers = {
    # Accessing [0] is safe due to the count condition
    vm_id = local.nodes_output.CLUSTER_NODES[0].vm_id
  }
  for_each = local.certificates_types
  connection {
    # Accessing [0] is safe due to the count condition
    host = local.nodes_output.CLUSTER_NODES[0].hostname
    user = var.USER_LOGIN
  }

  provisioner "remote-exec" {
    on_failure = fail
    inline = [
      "set -o errexit",
      "sudo mkdir -p ${local.source_ca_path}/$(dirname ${each.value}) ${local.target_ca_path}/$(dirname ${each.value})",
      "sudo env STEP_TOKEN=${data.external.step_k3s_ca_token[each.key].result.TOKEN} step ca certificate ${replace(each.value, "/", "-")} ${local.source_ca_path}/${each.value}.crt ${local.source_ca_path}/${each.value}.key --provisioner ${var.STEP_PROVISIONER_KUBE_CA}",
      "sudo cp ${local.source_ca_path}/${each.value}.crt ${local.target_ca_path}/${each.value}.crt",
      "sudo cp ${local.source_ca_path}/${each.value}.key ${local.target_ca_path}/${each.value}.key"
    ]
  }

}
