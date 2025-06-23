resource "yandex_dns_zone" "infrastructure_dns_zone" {
  name = var.dns_zone_params.name
  description = "DNS zone for infrastructure"
  folder_id = var.folder_id
  zone = var.dns_zone_params.zone
  public = var.dns_zone_params.is_public
}

resource "yandex_dns_recordset" "grafana" {
  zone_id = yandex_dns_zone.infrastructure_dns_zone.id
  name = "grafana"
  type = "A"
  ttl = 300
  data = [ data.kubernetes_service.nginx_ingress.status[0].load_balancer.0.ingress.0.ip ]
}

resource "yandex_dns_recordset" "notes-app" {
  zone_id = yandex_dns_zone.infrastructure_dns_zone.id
  name = "notes"
  type = "A"
  ttl = 300
  data = [ data.kubernetes_service.nginx_ingress.status[0].load_balancer.0.ingress.0.ip ]
}

resource "yandex_dns_recordset" "jenkins" {
  zone_id = yandex_dns_zone.infrastructure_dns_zone.id
  name = "jenkins"
  type = "A"
  ttl = 300
  data = [ yandex_compute_instance.jenkins.network_interface[0].nat_ip_address ]
}