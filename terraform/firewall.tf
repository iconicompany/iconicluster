# Получение параметров доступного шаблона брандмауэра по его имени и id созданного ВЦОД, который получили на шаге 4 при создании resource rustack_vdc (шаг 8)
data "rustack_firewall_template" "allow_default" {
  vdc_id = resource.rustack_vdc.iconicvdc.id
  name   = "По-умолчанию"
}
data "rustack_firewall_template" "allow_web" {
  vdc_id = resource.rustack_vdc.iconicvdc.id
  name   = "Разрешить WEB"
}

data "rustack_firewall_template" "allow_ssh" {
  vdc_id = resource.rustack_vdc.iconicvdc.id
  name   = "Разрешить SSH"
}

data "rustack_firewall_template" "allow_icmp" {
  vdc_id = resource.rustack_vdc.iconicvdc.id
  name   = "Разрешить ICMP"
}

data "rustack_firewall_template" "allow_any" {
  vdc_id = resource.rustack_vdc.iconicvdc.id
  name   = "Разрешить входящий трафик"
}

data "rustack_firewall_template" "allow_kubeapi" {
  vdc_id = resource.rustack_vdc.iconicvdc.id
  name   = "Сервер kubernetes"
}

data "rustack_firewall_template" "allow_mail" {
  vdc_id = resource.rustack_vdc.iconicvdc.id
  name   = "Почтовый сервер"
}

data "rustack_firewall_template" "allow_wireguard" {
  vdc_id = resource.rustack_vdc.iconicvdc.id
  name   = "Wireguard"
}

data "rustack_firewall_template" "allow_turn" {
  vdc_id = resource.rustack_vdc.iconicvdc.id
  name   = "Разрешить turn"
}

data "rustack_firewall_template" "allow_postgresql" {
  vdc_id = resource.rustack_vdc.iconicvdc.id
  name   = "postgresql"
}


data "rustack_firewall_template" "allow_stepca" {
  vdc_id = resource.rustack_vdc.iconicvdc.id
  name   = "stepca"
}
