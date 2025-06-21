resource "kubernetes_namespace" "monitoring" {
  depends_on = [ null_resource.get_kube_config ]
  metadata {
    name = var.monitoring_metadata.namespace
  }
}

resource "local_file" "grafana_values_yaml" {
  content = templatefile("${path.module}/templates/monitoring.yaml.tftpl", {
    grafana_domain = var.grafana_metadata.domain
    admin_username = var.grafana_metadata.admin_user
    admin_password = var.grafana_metadata.admin_password
  })
  filename = "${path.module}/helm_values/monitoring.yaml"
}

resource "helm_release" "kube-prometheus-stack" {
  depends_on = [ kubernetes_namespace.monitoring, local_file.grafana_values_yaml ]
  name = var.monitoring_metadata.name
  namespace = var.monitoring_metadata.namespace
  version = var.monitoring_metadata.version
  repository = var.monitoring_metadata.repository
  chart = var.monitoring_metadata.chart
  values = [ 
    "${file("${path.module}/helm_values/monitoring.yaml")}"
   ]
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