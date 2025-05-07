variable "acr_name" {
  description = "The name of the container registry"
  type        = string
  default     = ""
}

variable "acr_resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = ""
}

variable "acr_location" {
  description = "The location of the container registry"
  type        = string
  default     = ""
}

variable "acr_sku" {
  description = "The SKU of the container registry"
  type        = string
  default     = "standard"
}

variable "acr_admin_enabled" {
  description = "Specifies whether the admin user is enabled"
  type        = bool
  default     = false
}