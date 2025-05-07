resource "azurerm_machine_learning_compute_cluster" "gpu_cluster" {
  name                          = var.name
  location                      = var.location
  machine_learning_workspace_id = var.machine_learning_workspace_id

  vm_priority = var.vm_priority
  vm_size     = var.vm_size

  scale_settings {
    min_node_count                       = var.min_nodes
    max_node_count                       = var.max_nodes
    scale_down_nodes_after_idle_duration = var.scale_down_nodes_after_idle_duration
  }

  identity {
    type = "SystemAssigned"
  }

  # Add subnet configuration to match storage account's VNet
  subnet_resource_id        = var.subnet_id
  ssh_public_access_enabled = var.ssh_public_access_enabled

  # Add SSH configuration if admin username is provided
  dynamic "ssh" {
    for_each = var.ssh_admin_username != null ? [1] : []
    content {
      admin_username = var.ssh_admin_username
      admin_password = var.ssh_admin_password
      key_value      = var.ssh_key_value
    }
  }

}
