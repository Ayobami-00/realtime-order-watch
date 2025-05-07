data "azurerm_kubernetes_service_versions" "current" {
  location        = var.aks_location
  include_preview = false
}

resource "azurerm_kubernetes_cluster_node_pool" "linux101" {
  auto_scaling_enabled  = var.auto_scaling_enabled
  kubernetes_cluster_id = var.kubernetes_cluster_id
  max_count             = var.max_count
  min_count             = var.min_count
  mode                  = var.mode
  name                  = var.name
  orchestrator_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  os_disk_size_gb       = var.os_disk_size_gb
  os_type               = var.os_type # Default is Linux, we can change to Windows
  vm_size               = var.vm_size
  priority              = var.priority # Default is Regular, we can change to Spot with additional settings like eviction_policy, spot_max_price, node_labels and node_taints
  vnet_subnet_id        = var.vnet_subnet_id
  node_labels = var.node_labels
  tags = var.tags
}
