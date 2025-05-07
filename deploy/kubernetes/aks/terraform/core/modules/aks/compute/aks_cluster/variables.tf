variable "name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "aks_location" {
  description = "Location of the AKS cluster"
  type        = string
}


variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}


variable "dns_prefix" {
  description = "DNS prefix"
  type        = string
}


variable "node_resource_group_name" {
  description = "Node resource group name"
  type        = string
}


variable "default_node_pool_name" {
  description = "Name of the default node pool"
  type        = string
}


variable "default_node_pool_vm_size" {
  description = "VM size of the default node pool"
  type        = string
  default     = "Standard_B2ms"
}


# variable "default_node_pool_zones" {
#   description = "Zones of the default node pool"
#   type        = list(string)
#   default     = [1, 2, 3]
# }


variable "default_node_pool_min_count" {
  description = "Minimum count of the default node pool"
  type        = number
  default     = 1
}


variable "default_node_pool_max_count" {
  description = "Maximum count of the default node pool"
  type        = number
  default     = 3
}


variable "default_node_pool_os_disk_size_gb" {
  description = "OS disk size of the default node pool"
  type        = number
  default     = 30
}


variable "default_node_pool_vnet_subnet_id" {
  description = "Vnet subnet ID of the default node pool"
  type        = string
}


variable "default_node_pool_node_labels" {
  description = "Node labels of the default node pool"
  type        = map(string)
}


variable "default_node_pool_tags" {
  description = "Tags of the default node pool"
  type        = map(string)
}


variable "identity_type" {
  description = "Type of the identity"
  type        = string
  default     = "SystemAssigned"
}


variable "log_analytics_workspace_id" {
  description = "Log analytics workspace ID"
  type        = string
}


variable "admin_group_object_ids" {
  description = "Admin group object IDs"
  type        = list(string)
}


variable "ssh_key" {
  description = "SSH key"
  type        = string
}


variable "network_plugin" {
  description = "Network plugin"
  type        = string
  default     = "azure"
}


variable "load_balancer_sku" {
  description = "Load balancer SKU"
  type        = string
  default     = "standard"
}


variable "tags" {
  description = "Tags"
  type        = map(string)
}



variable "service_cidr" {
  description = "Service CIDR"
  type        = string
  default     = "10.0.0.0/16"
} 


variable "dns_service_ip" {
  description = "DNS service IP"
  type        = string
  default     = "10.0.0.10"
}


variable "oidc_issuer_enabled" {
  description = "OIDC issuer enabled"
  type        = bool
  default     = true
}


variable "workload_identity_enabled" {
  description = "Workload identity enabled"
  type        = bool
  default     = true
}

