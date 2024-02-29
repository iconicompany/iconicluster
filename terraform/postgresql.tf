resource "terraform_data" "postgresqlname" {
  count = var.SERVERS_NUM
  input = "postgresql${count.index + 10}.${var.CLUSTER_TLD}"
}

# generate token for DB client certificate
data "external" "step_postgresql_token" {
  count   = var.SERVERS_NUM
  program = ["bash", "${path.module}/step-ca-token.sh"]

  query = {
    STEPPATH           = var.STEPPATH
    STEP_PROVISIONER   = var.STEP_PROVISIONER
    STEP_PASSWORD_FILE = var.STEP_PASSWORD_FILE
    CN                 = terraform_data.postgresqlname[count.index].output
  }
}

# generate DB client certificate
resource "null_resource" "step_postgresql_server" {
  count = var.SERVERS_NUM
  depends_on = [null_resource.step_cli]
  triggers = {
    vm_id = rustack_vm.cluster[count.index].id
  }
  connection {
    host = rustack_vm.cluster[count.index].floating_ip
    user = var.USER_LOGIN
  }

  provisioner "remote-exec" {
    on_failure = fail
    inline = [
      "export STEP_TOKEN=${data.external.step_postgresql_token[count.index].result.TOKEN}",
      "curl -Ls https://github.com/iconicompany/iconicluster/raw/main/postgresql/postgresql-server.sh | bash -s - ${terraform_data.postgresqlname[count.index].output}",
    ]
  }

}


