data "rustack_dns" "cluster_dns" {
  name       = "${var.CLUSTER_TLD}."
  project_id = data.rustack_project.iconicproject.id
}

resource "rustack_dns_record" "node_ws_record" {
  for_each = { for idx, node in local.nodes_output.CLUSTER_NODES : idx => node }
  dns_id = data.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${each.value.hostname}."
  data   = each.value.hostname
}

resource "rustack_dns_record" "agent_ws_record" {
  for_each = { for idx, node in local.nodes_output.AGENT_NODES : idx => node }
  dns_id = data.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${each.value.hostname}." # Corrected to use agent hostname
  data   = each.value.hostname   # Corrected to use agent external_ip
}

resource "rustack_dns_record" "cluster_ws_record" {
  # Creates an A record for the main cluster FQDN for each cluster node
  # This allows round-robin DNS if multiple master nodes exist.
  for_each = { for idx, node in local.nodes_output.CLUSTER_NODES : idx => node }
  dns_id = data.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${local.CLUSTER_NAME}."
  data   = each.value.hostname
}

resource "rustack_dns_record" "add_cluster_record" {
  # Creates wildcard A records for additional domains, pointing to the first cluster node's IP.
  # Only create these if there's at least one cluster node and var.ADD_DOMAIN is not empty.
  for_each = length(local.nodes_output.CLUSTER_NODES) > 0 ? toset(var.ADD_DOMAIN) : []
  dns_id = data.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "*.${each.key}.${var.CLUSTER_TLD}."
  # Ensure CLUSTER_NODES is not empty before accessing index [0]
  data   = length(local.nodes_output.CLUSTER_NODES) > 0 ? local.nodes_output.CLUSTER_NODES[0].hostname : null
}


data "rustack_dns" "cluster_dns2" {
  name       = "${var.CLUSTER_TLD2}."
  project_id = data.rustack_project.iconicproject.id
}

resource "rustack_dns_record" "add_cluster_record2" {
  # Creates wildcard A records for additional domains on the second TLD,
  # pointing to the first cluster node's IP.
  # Only create these if there's at least one cluster node and var.ADD_DOMAIN is not empty.
  for_each = length(local.nodes_output.CLUSTER_NODES) > 0 ? toset(var.ADD_DOMAIN) : []
  dns_id = data.rustack_dns.cluster_dns2.id
  type   = "A"
  host   = "*.${each.key}.${var.CLUSTER_TLD2}."
  # Ensure CLUSTER_NODES is not empty before accessing index [0]
  data   = length(local.nodes_output.CLUSTER_NODES) > 0 ? local.nodes_output.CLUSTER_NODES[0].hostname : null
}
