variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
  default     = ""
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = ""
}

variable "location" {
  description = "The location of the resource group"
  type        = string
  default     = ""
}


variable "account_tier" {
  description = "The tier of the storage account"
  type        = string
  default     = "Standard"
}


variable "account_replication_type" {
  description = "The replication type of the storage account"
  type        = string
  default     = "LRS"
}

variable "access_mode" {
  type        = string
  description = "Access mode for storage account: 'private' or 'public'"
  default     = "public"
  validation {
    condition     = contains(["private", "public"], var.access_mode)
    error_message = "access_mode must be either 'private' or 'public'"
  }
}

variable "public_network_access_enabled" {
  type    = bool
  default = true
}

variable "enable_https_traffic_only" {
  type    = bool
  default = true
}

variable "min_tls_version" {
  type    = string
  default = "TLS1_2"
}

variable "default_action" {
  type    = string
  default = "Allow"
}

variable "ip_rules" {
  type    = list(string)
  default = []
}

variable "virtual_network_subnet_ids" {
  type    = list(string)
  default = []
}

variable "bypass" {
  type    = list(string)
  default = ["AzureServices"]
}

