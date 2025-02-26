data "rustack_dns" "cluster_dns" {
  name       = "${var.CLUSTER_TLD}."
  project_id = data.rustack_project.iconicproject.id
}

resource "rustack_dns_record" "node_ws_record" {
  count  = var.SERVERS_NUM
  dns_id = data.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${resource.terraform_data.hostname[count.index].output}."
  data   = resource.rustack_vm.cluster[count.index].floating_ip
}
resource "rustack_dns_record" "agent_ws_record" {
  count  = var.AGENTS_NUM
  dns_id = data.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${resource.terraform_data.agentname[count.index].output}."
  data   = resource.rustack_vm.agent[count.index].floating_ip
}

resource "rustack_dns_record" "cluster_ws_record" {
  count  = var.SERVERS_NUM
  dns_id = data.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${local.CLUSTER_NAME}."
  data   = resource.rustack_vm.cluster[count.index].floating_ip
}

resource "rustack_dns_record" "add_cluster_record" {
  count  = var.SERVERS_NUM > 0 ? length(var.ADD_DOMAIN) : 0
  dns_id = data.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "*.${var.ADD_DOMAIN[count.index]}.${var.CLUSTER_TLD}."
  data   = resource.rustack_vm.cluster[0].floating_ip
}


data "rustack_dns" "cluster_dns2" {
  name       = "${var.CLUSTER_TLD2}."
  project_id = data.rustack_project.iconicproject.id
}

resource "rustack_dns_record" "add_cluster_record2" {
  count  = var.SERVERS_NUM > 0 ? length(var.ADD_DOMAIN) : 0
  dns_id = data.rustack_dns.cluster_dns2.id
  type   = "A"
  host   = "*.${var.ADD_DOMAIN[count.index]}.${var.CLUSTER_TLD2}."
  data   = resource.rustack_vm.cluster[0].floating_ip
}
