output "thanos_query_service_name" {
  description = "Name of the Thanos Query service (Helm release name)."
  value       = var.query_enabled ? helm_release.thanos.name : null
}

output "thanos_query_service_endpoint" {
  description = "ClusterIP or LoadBalancer IP for Thanos Query (if applicable)."
  value       = var.query_enabled && var.query_service_type != "ClusterIP" ? "Access via LoadBalancer (details require manual check or data source after apply)" : "Access via ClusterIP within the cluster"
  # Note: Accessing service details like LoadBalancer IP directly from helm_release is complex.
  # For LoadBalancer, you might need a `data "kubernetes_service"` source to get the external IP after Helm applies it.
  # You typically access Query via Grafana or port-forwarding for ClusterIP.
}

output "thanos_helm_release_status" {
  description = "Status of the Thanos Helm release."
  value       = helm_release.thanos.status
}
