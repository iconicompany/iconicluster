resource "terraform_data" "mongodbname" {
  count = var.MONGODB_NUM
  input = "mongodb0${count.index + 1}.${local.CLUSTER_NAME}"
}

resource "rustack_dns_record" "mongodb_dns_record" {
  # Create a DNS record for each of the first MONGODB_NUM cluster nodes,
  # or fewer if there are not enough cluster nodes.
  # This assumes MongoDB instances are associated with these cluster nodes.
  for_each = {
    for i in range(min(var.MONGODB_NUM, length(local.nodes_output.CLUSTER_NODES))) :
    i => {
      # Use the pre-generated hostname for MongoDB
      hostname    = terraform_data.mongodbname[i].output
      # Get the external IP from the corresponding cluster node
      external_ip = local.nodes_output.CLUSTER_NODES[i].external_ip
    }
  }
  dns_id = data.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${each.value.hostname}."
  data   = each.value.external_ip
}
