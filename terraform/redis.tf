resource "terraform_data" "redisname" {
  count = var.REDIS_NUM
  input = "redis0${count.index + 1}.${local.CLUSTER_NAME}"
}

resource "rustack_dns_record" "redis_dns_record" {
  count  = var.REDIS_NUM
  dns_id = data.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${terraform_data.redisname[count.index].output}."
  data   = module.nodes.cluster_external_ips[count.index]
}
