
variable "name" {
  description = "The name of the machine learning workspace"
  type        = string
}


variable "location" {
  description = "The location of the machine learning workspace"
  type        = string
}


variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}


variable "application_insights_id" {
  description = "The ID of the application insights"
  type        = string
}


variable "container_registry_id" {
  description = "The ID of the container registry"
  type        = string
}


variable "key_vault_id" {
  description = "The ID of the key vault"
  type        = string
}


variable "storage_account_id" {
  description = "The ID of the storage account"
  type        = string
}


variable "tags" {
  description = "The tags to apply to the machine learning workspace"
  type        = map(string)
}

variable "public_network_access_enabled" {
  description = "Whether to enable public network access"
  type        = bool
  default     = true  
}

variable "identity_type" {
  description = "The type of identity to use for the machine learning workspace"
  type        = string
  default     = "SystemAssigned"
}


      