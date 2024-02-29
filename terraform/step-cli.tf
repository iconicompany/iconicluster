data "external" "ssh_token" {
  count = var.SERVERS_NUM
  program = ["bash", "${path.module}/step-ca-token.sh"]

  query = {
    STEPPATH     = var.STEPPATH
    STEP_PROVISIONER = var.STEP_PROVISIONER
    STEP_PASSWORD_FILE = var.STEP_PASSWORD_FILE
    STEP_SSH     = 1
    STEP_HOST    = 1
    CN            = resource.terraform_data.hostname[count.index].output
  }
}


// Install step-cli
resource "null_resource" "step_cli" {
  count = var.SERVERS_NUM
  triggers = {
    vm_id = rustack_vm.cluster[count.index].id
  }
  connection {
        #host     = resource.terraform_data.hostname[count.index].output
        host      = rustack_vm.cluster[count.index].floating_ip
        user      = var.USER_LOGIN
  }

  provisioner "remote-exec" {
    on_failure = fail
    inline = [
      "curl -Ls https://github.com/iconicompany/iconicluster/step-ca/raw/main/install/step-cli.sh | bash -",
      "curl -Ls https://github.com/iconicompany/iconicluster/step-ca/raw/main/install/step-sshd.sh |  env STEP_TOKEN=${data.external.ssh_token[count.index].result.TOKEN} bash -",
    ]
  }
}
