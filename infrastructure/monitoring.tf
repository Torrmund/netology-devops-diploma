resource "kubernetes_namespace" "monitoring" {
  depends_on = [ null_resource.get_kube_config ]
  metadata {
    name = var.monitoring_metadata.namespace
  }
}

resource "local_file" "grafana_values_yaml" {
  content = local.grafana_values
  filename = "${path.module}/helm_values/monitoring.yaml"
}

resource "helm_release" "kube-prometheus-stack" {
  depends_on = [ kubernetes_namespace.monitoring, local_file.grafana_values_yaml ]
  name = var.monitoring_metadata.name
  namespace = var.monitoring_metadata.namespace
  version = var.monitoring_metadata.version
  repository = var.monitoring_metadata.repository
  chart = var.monitoring_metadata.chart
  values = [ local.grafana_values ]
}
