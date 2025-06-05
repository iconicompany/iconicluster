resource "terraform_data" "postgresqlname" {
  count = var.POSTGRESQL_NUM
  input = "postgresql0${count.index + 1}.${local.CLUSTER_NAME}"
}

locals {
  # Map of PostgreSQL instances to be configured on actual cluster nodes.
  # The key is the string representation of the index (e.g., "0", "1").
  # The value contains details for that PostgreSQL instance and the
  # cluster node it will run on.
  postgresql_instances_on_nodes = {
    for i in range(min(var.POSTGRESQL_NUM, length(local.nodes_output.CLUSTER_NODES))) :
    tostring(i) => { # Use tostring(i) for the key to match data.external access
      pg_hostname      = terraform_data.postgresqlname[i].output
      node_external_ip = local.nodes_output.CLUSTER_NODES[i].hostname
      node_vm_id       = local.nodes_output.CLUSTER_NODES[i].vm_id
    }
  }
}

resource "rustack_dns_record" "postgresql_dns_record" {
  for_each = local.postgresql_instances_on_nodes
  dns_id = data.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${each.value.pg_hostname}."
  data   = each.value.node_external_ip
}


# install postgresql server
resource "null_resource" "postgresql_server" {
  for_each = local.postgresql_instances_on_nodes
  triggers = {
    vm_id = each.value.node_vm_id
  }
  connection {
    host = each.value.node_external_ip
    user = var.USER_LOGIN
  }
  provisioner "remote-exec" {
    on_failure = fail
    inline     = ["sudo apt update && sudo apt install  --no-upgrade -y  postgresql postgresql-client"]
  }
}

# generate token for DB client certificate
data "external" "step_postgresql_token" {
  # This generates tokens for all *intended* PostgreSQL instances,
  # based on var.POSTGRESQL_NUM and terraform_data.postgresqlname.
  count   = var.POSTGRESQL_NUM
  program = ["bash", "${path.module}/step-ca-token.sh"]

  query = {
    STEPPATH           = var.STEPPATH
    STEP_PROVISIONER   = var.STEP_PROVISIONER
    STEP_PASSWORD_FILE = var.STEP_PASSWORD_FILE
    CN                 = element(terraform_data.postgresqlname.*.output, count.index)
  }
}

# generate DB client certificate
resource "null_resource" "step_postgresql" {
  for_each   = local.postgresql_instances_on_nodes
  depends_on = [null_resource.step_cli, null_resource.postgresql_server]
  triggers = {
    vm_id = each.value.node_vm_id
  }
  connection {
    host = each.value.node_external_ip
    user = var.USER_LOGIN
  }

  provisioner "remote-exec" {
    on_failure = fail
    inline = [
      # each.key from local.postgresql_instances_on_nodes is the string index "0", "1", etc.
      # data.external.step_postgresql_token is a list, so we need to convert each.key to a number.
      "export STEP_TOKEN=${data.external.step_postgresql_token[tonumber(each.key)].result.TOKEN}",
      "curl -Ls https://github.com/iconicompany/iconicluster/raw/main/step-ca/install/step-postgresql.sh | bash -s - ${each.value.pg_hostname}",
    ]
  }
}
