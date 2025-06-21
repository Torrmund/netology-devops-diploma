resource "kubernetes_namespace" "demo_app_namespace" {
  metadata {
    name = var.demo_app_namespace
  }
}

resource "helm_release" "postgresql" {
  depends_on = [ kubernetes_namespace.demo_app_namespace ]
  name = var.postgresql_metadata.name
  namespace = var.demo_app_namespace
  repository = var.postgresql_metadata.repository
  chart = var.postgresql_metadata.chart
  version = var.postgresql_metadata.version

  set = [ {
    name = "auth.database"
    value = var.postgresql_metadata.database
},
    {
    name = "auth.username"
    value = var.postgresql_username
},
    {
    name = "auth.password"
    value = var.postgresql_password
},
    {
    name = "existingSecret"
    value = var.postgresql_metadata.existing_secret
},
    {
    name = "primary.persistence.enabled"
    value = var.postgresql_metadata.primary_persistence_enabled
},
    {
    name = "primary.persistence.size"
    value = var.postgresql_metadata.primary_persistence_size
    }
   ]
}