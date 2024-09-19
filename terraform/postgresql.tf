resource "terraform_data" "postgresqlname" {
  count = var.SERVERS_NUM
  input = "postgresql0${count.index+1}.${local.CLUSTER_NAME}"
}

resource "rustack_dns_record" "postgresql_dns_record" {
  count  = var.SERVERS_NUM
  dns_id = resource.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${terraform_data.postgresqlname[count.index].output}."
  data   = resource.rustack_vm.cluster[count.index].floating_ip
}


# install postgresql server
resource "null_resource" "postgresql_server" {
  count = var.SERVERS_NUM
  triggers = {
    vm_id = rustack_vm.cluster[count.index].id
  }
  connection {
    host = rustack_vm.cluster[count.index].floating_ip
    user = var.USER_LOGIN
  }
  provisioner "remote-exec" {
    on_failure = fail
    inline     = ["sudo apt update && sudo apt install  --no-upgrade -y  postgresql postgresql-client"]
  }

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
resource "null_resource" "step_postgresql" {
  count      = var.SERVERS_NUM
  depends_on = [null_resource.step_cli, null_resource.postgresql_server]
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
      "curl -Ls https://github.com/iconicompany/iconicluster/raw/main/step-ca/install/step-postgresql.sh | bash -s - ${terraform_data.postgresqlname[count.index].output}",
    ]
  }

}


