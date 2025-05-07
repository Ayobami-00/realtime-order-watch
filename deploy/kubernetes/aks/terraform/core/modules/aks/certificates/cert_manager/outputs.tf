output "cert_manager_namespace" {
  value = helm_release.cert_manager.namespace
}

output "cert_manager_release_name" {
  value = helm_release.cert_manager.name
}