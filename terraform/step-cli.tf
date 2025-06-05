data "external" "ssh_token" {
  count = var.SERVERS_NUM
  program = ["bash", "${path.module}/step-ca-token.sh"]

  query = {
    STEPPATH     = var.STEPPATH
    STEP_PROVISIONER = var.STEP_PROVISIONER
    STEP_PASSWORD_FILE = var.STEP_PASSWORD_FILE
    STEP_SSH     = 1
    STEP_HOST    = 1
    CN            = module.nodes.cluster_hostnames[count.index]
  }
}


// Install step-cli
resource "null_resource" "step_cli" {
  count = var.SERVERS_NUM
  triggers = {
    vm_id = module.nodes.cluster_vm_ids[count.index]
  }
  connection {
        #host     = module.nodes.cluster_hostnames[count.index]
        host      = module.nodes.cluster_floating_ips[count.index]
        user      = var.USER_LOGIN
  }

  provisioner "remote-exec" {
    on_failure = fail
    inline = [
      "set -o errexit",
      "curl -Ls https://github.com/iconicompany/iconicluster/raw/main/step-ca/install/step-cli.sh | bash -",
      "curl -Ls https://github.com/iconicompany/iconicluster/raw/main/step-ca/install/step-sshd.sh |  env STEP_TOKEN=${data.external.ssh_token[count.index].result.TOKEN} bash -",
    ]
  }
}
