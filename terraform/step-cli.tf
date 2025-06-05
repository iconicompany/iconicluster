data "external" "ssh_token" {
  for_each = { for idx, node in local.nodes_output.CLUSTER_NODES : idx => node }
  program = ["bash", "${path.module}/step-ca-token.sh"]

  query = {
    STEPPATH           = var.STEPPATH
    STEP_PROVISIONER   = var.STEP_PROVISIONER
    STEP_PASSWORD_FILE = var.STEP_PASSWORD_FILE
    STEP_SSH           = 1
    STEP_HOST          = 1
    CN                 = each.value.hostname
  }
}


// Install step-cli
resource "null_resource" "step_cli" {
  for_each = { for idx, node in local.nodes_output.CLUSTER_NODES : idx => node }
  triggers = {
    vm_id = each.value.vm_id
  }
  connection {
    host = each.value.external_ip
    user = var.USER_LOGIN
  }

  provisioner "remote-exec" {
    on_failure = fail
    inline = [
      "set -o errexit",
      "curl -Ls https://github.com/iconicompany/iconicluster/raw/main/step-ca/install/step-cli.sh | bash -",
      "curl -Ls https://github.com/iconicompany/iconicluster/raw/main/step-ca/install/step-sshd.sh |  env STEP_TOKEN=${data.external.ssh_token[each.key].result.TOKEN} bash -",
    ]
  }
}
