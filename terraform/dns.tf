data "rustack_dns" "cluster_dns" {
  name       = "${local.CLUSTER_TLD}."
  project_id = data.rustack_project.iconicproject.id
}

resource "rustack_dns_record" "node_ws_record" {
  for_each = { for idx, node in local.nodes_output.CLUSTER_NODES : idx => node }
  dns_id = data.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${each.value.hostname}."
  data   = each.value.external_ip
}

resource "rustack_dns_record" "agent_ws_record" {
  for_each = { for idx, node in local.nodes_output.AGENT_NODES : idx => node }
  dns_id = data.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${each.value.hostname}." # Corrected to use agent hostname
  data   = each.value.external_ip   # Corrected to use agent external_ip
}

resource "rustack_dns_record" "cluster_ws_record" {
  # Creates an A record for the main cluster FQDN for each cluster node
  # This allows round-robin DNS if multiple master nodes exist.
  for_each = { for idx, node in local.nodes_output.CLUSTER_NODES : idx => node }
  dns_id = data.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${var.CLUSTER_DOMAIN}."
  data   = each.value.external_ip
}

locals {
  domains_with_tld = {
    for domain in var.ADD_DOMAIN :
    domain => join(".", slice(split(".", domain), length(split(".", domain)) - 2, length(split(".", domain))))
  }

  # Получим уникальные TLD
  unique_tlds = toset(values(local.domains_with_tld))
}

data "rustack_dns" "tld" {
  for_each   = local.unique_tlds
  name       = "${each.value}."
  project_id = data.rustack_project.iconicproject.id
}

resource "rustack_dns_record" "records" {

  for_each = length(local.nodes_output.CLUSTER_NODES) > 0 ? toset(var.ADD_DOMAIN) : []
  dns_id = data.rustack_dns.tld[local.domains_with_tld[each.key]].id
  type   = "A"
  host   = "*.${each.key}."
  # Ensure CLUSTER_NODES is not empty before accessing index [0]
  data   = length(local.nodes_output.CLUSTER_NODES) > 0 ? local.nodes_output.CLUSTER_NODES[0].external_ip : null

}
