resource "kubernetes_namespace" "namespace" {
  metadata {
    labels = {
      "name" = var.namespace
    }
    name = var.namespace
  }
}