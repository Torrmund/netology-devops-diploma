resource "yandex_vpc_network" "infrastructure_vpc" {
  name = var.vpc_params.name
}

resource "yandex_vpc_subnet" "infrastructure_vpc_subnets" {
  depends_on = [ yandex_vpc_network.infrastructure_vpc ]
  for_each = var.vpc_params.subnets
  name = each.key
  zone = each.value.zone
  network_id = yandex_vpc_network.infrastructure_vpc.id
  v4_cidr_blocks = [ each.value.cidr ]
}
