# Получение параметров доступного шаблона брандмауэра по его имени и id созданного ВЦОД, который получили на шаге 4 при создании resource rustack_vdc (шаг 8)
data "rustack_firewall_template" "default" {
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = "По-умолчанию"
}
data "rustack_firewall_template" "web" {
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = "Разрешить WEB"
}

data "rustack_firewall_template" "ssh" {
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = "Разрешить SSH"
}

data "rustack_firewall_template" "icmp" {
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = "Разрешить ICMP"
}

data "rustack_firewall_template" "any" {
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = "Разрешить входящий трафик"
}

data "rustack_firewall_template" "kubeapi" {
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = "Сервер kubernetes"
}

data "rustack_firewall_template" "mail" {
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = "Почтовый сервер"
}

data "rustack_firewall_template" "wireguard" {
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = "Wireguard"
}

data "rustack_firewall_template" "turn" {
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = "Разрешить turn"
}

data "rustack_firewall_template" "postgresql" {
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = "postgresql"
}


data "rustack_firewall_template" "stepca" {
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = "stepca"
}

data "rustack_firewall_template" "mongodb" {
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = "mongodb"
}

data "rustack_firewall_template" "temporal" {
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = "temporal"
}

data "rustack_firewall_template" "redis" {
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = "redis"
}

resource "rustack_firewall_template" "nebula" {
  vdc_id = data.rustack_vdc.iconicvdc.id
  name   = "nebula"
  tags = ["created_by:terraform"]
}

resource "rustack_firewall_template_rule" "nebula_rule" {
    firewall_id = resource.rustack_firewall_template.nebula.id
    name = "nebula"
    direction = "ingress"
    protocol = "udp"
    port_range = "4242"
    destination_ip = "0.0.0.0/0"
}
