# Resource: MySQL Cluster IP Service
resource "kubernetes_service_v1" "service" {
  metadata {
    name = "${var.application_name}-service"
  }
  spec {
    selector = {
      app = var.application_name
    }
    port {
      name        = "tcp"
      port        = 80 # Service Port
      target_port = var.application_port
    }
    type = var.application_service_type
  }
}
