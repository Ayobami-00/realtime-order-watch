data "azurerm_kubernetes_service_versions" "current" {
  location        = var.aks_location
  include_preview = false
}



resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.name
  location            = var.aks_location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  node_resource_group = var.node_resource_group_name

  default_node_pool {
    name                 = var.default_node_pool_name
    vm_size              = var.default_node_pool_vm_size
    orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
    auto_scaling_enabled = true
    max_count            = var.default_node_pool_max_count
    min_count            = var.default_node_pool_min_count
    os_disk_size_gb      = var.default_node_pool_os_disk_size_gb
    type                 = "VirtualMachineScaleSets"
    vnet_subnet_id       = var.default_node_pool_vnet_subnet_id
    node_labels          = var.default_node_pool_node_labels
    tags                 = var.default_node_pool_tags
  }

  identity {
    type = var.identity_type
  }

  # Added June 2023
  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  azure_active_directory_role_based_access_control {
    admin_group_object_ids = var.admin_group_object_ids
  }

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = var.ssh_key
    }
  }

  # Network Profile
  network_profile {
    network_plugin    = var.network_plugin
    load_balancer_sku = var.load_balancer_sku
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip

  }

  tags = var.tags

  oidc_issuer_enabled = var.oidc_issuer_enabled
  workload_identity_enabled = var.workload_identity_enabled
}
