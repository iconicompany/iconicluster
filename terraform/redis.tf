resource "terraform_data" "redisname" {
  count = var.REDIS_NUM
  input = "redis0${count.index + 1}.${local.CLUSTER_DOMAIN}"
}

resource "rustack_dns_record" "redis_dns_record" {
  # Create a DNS record for each of the first REDIS_NUM cluster nodes,
  # or fewer if there are not enough cluster nodes.
  # This assumes Redis instances are associated with these cluster nodes.
  for_each = {
    for i in range(min(var.REDIS_NUM, length(local.nodes_output.CLUSTER_NODES))) :
    i => {
      # Use the pre-generated hostname for Redis
      hostname    = terraform_data.redisname[i].output
      # Get the external IP from the corresponding cluster node
      external_ip = local.nodes_output.CLUSTER_NODES[i].external_ip
    }
  }
  dns_id = data.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${each.value.hostname}."
  data   = each.value.external_ip
}
