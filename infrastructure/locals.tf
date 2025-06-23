locals {
  grafana_values = templatefile("${path.module}/templates/monitoring.yaml.tftpl", {
    grafana_domain = var.grafana_metadata.domain
    admin_username = var.grafana_metadata.admin_user
    admin_password = var.grafana_metadata.admin_password
  })

  ingress_monitoring_manifest = templatefile("${path.module}/templates/ingress-monitoring.yaml.tftpl", {
    grafana_domain = var.grafana_metadata.domain
  })
}