resource "yandex_dns_zone" "infrastructure_dns_zone" {
  name = var.dns_zone_params.name
  description = "DNS zone for infrastructure"
  folder_id = var.folder_id
  zone = var.dns_zone_params.zone
  public = var.dns_zone_params.is_public
}