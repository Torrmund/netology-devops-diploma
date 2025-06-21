resource "kubernetes_namespace" "ingress" {
  depends_on = [ null_resource.get_kube_config ]
  metadata {
    name = var.ingress_metadata.namespace
  }
}

resource "helm_release" "ingress-nginx" {
  depends_on = [ kubernetes_namespace.ingress ]
  name = var.ingress_metadata.name
  namespace = var.ingress_metadata.namespace
  version = var.ingress_metadata.version
  repository = var.ingress_metadata.repository
  chart = var.ingress_metadata.chart
  values = [ 
    "${file("${path.module}/helm_values/ingress-controller.yaml")}"
  ]
}

data "kubernetes_service" "nginx_ingress" {
  depends_on = [ helm_release.ingress-nginx ]
  metadata {
    name = "ingress-nginx-controller"
    namespace = var.ingress_metadata.namespace
  }
}

resource "local_file" "ingress_monitoring_manifest" {
  content = templatefile("${path.module}/templates/ingress-monitoring.yaml.tftpl", {
    grafana_domain = var.grafana_metadata.domain
  })
  filename = "${path.module}/k8s_manifests/ingress-monitoring.yaml"
}

resource "kubectl_manifest" "ingress_monitoring" {
  depends_on = [ helm_release.ingress-nginx, helm_release.kube-prometheus-stack ]
  yaml_body = file("${path.module}/k8s_manifests/ingress-monitoring.yaml")
}