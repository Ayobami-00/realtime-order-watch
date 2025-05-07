
variable "name" {
  description = "Name of the key vault"
  type        = string
}



variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}



variable "aks_location" {
  description = "Location of the AKS cluster"
  type        = string
}


variable "soft_delete_retention_days" {
  description = "Soft Delete Retention Days"
  type        = number
  default     = 7
}


variable "purge_protection_enabled" {
  description = "Purge Protection Enabled"
  type        = bool
  default     = false
}


variable "sku_name" {
  description = "SKU Name"
  type        = string
  default     = "standard"
}



