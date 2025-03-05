resource "terraform_data" "mongodbname" {
  count = var.MONGODB_NUM
  input = "mongodb0${count.index+1}.${local.CLUSTER_NAME}"
}

resource "rustack_dns_record" "mongodb_dns_record" {
  count  = var.MONGODB_NUM
  dns_id = data.rustack_dns.cluster_dns.id
  type   = "A"
  host   = "${terraform_data.mongodbname[count.index].output}."
  data   = resource.rustack_vm.cluster[count.index].floating_ip
}
