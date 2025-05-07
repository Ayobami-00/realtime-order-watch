# Resource: UserMgmt WebApp Kubernetes Deployment
resource "kubernetes_deployment_v1" "deployment" {
  metadata {
    name = "${var.application_name}-deployment"
    labels = merge(
      {
        app = var.application_name
      },
      var.application_tags
    )
  }

  spec {
    replicas = var.application_replicas
    selector {
      match_labels = {
        app = var.application_name
      }
    }
    template {
      metadata {
        labels = {
          app = var.application_name
        }
      }
      spec {
        dynamic "volume" {
          for_each = var.create_volume ? [1] : []
          content {
            name = "${var.application_name}-persistent-storage"
            persistent_volume_claim {
              claim_name = kubernetes_persistent_volume_claim_v1.pvc[0].metadata.0.name
            }
          }
        }
        container {
          name  = var.application_name
          image = var.application_image

          #   image_pull_policy = "always"  # Defaults to Always so we can comment this
          port {
            container_port = var.application_port
          }

          dynamic "env" {
            for_each = var.application_envs

            content {
              name  = env.key
              value = env.value
            }
          }
          dynamic "volume_mount" {
            for_each = var.create_volume ? [1] : []
            content {
              name       = "${var.application_name}-persistent-storage"
              mount_path = var.application_volume_mount_path
            }
          }
        }
      }
    }
  }
}
