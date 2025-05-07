
output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}


output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.id
}


output "aks_cluster_node_resource_group_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
}


output "aks_cluster_node_resource_group_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.node_resource_group_id
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.aks_cluster.oidc_issuer_url
}

output "kubelet_identity" {
  value = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity
}


