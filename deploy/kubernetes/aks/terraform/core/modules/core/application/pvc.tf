# Resource: Persistent Volume Claim
resource "kubernetes_persistent_volume_claim_v1" "pvc" {
  count = var.create_pvc ? 1 : 0
  metadata {
    name = "${var.application_name}-pv-claim"
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.application_pvc_storage_class_name
    resources {
      requests = {
        storage = var.application_pvc_storage_amount
      }
    }
  }
}
