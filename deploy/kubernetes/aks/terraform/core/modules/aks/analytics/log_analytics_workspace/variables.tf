
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = ""
}

variable "aks_location" {
  description = "The location of the AKS cluster"
  type        = string
  default     = ""
}

variable "retention_in_days" {
  description = "The retention period for the log analytics workspace"
  type        = number
  default     = 30
} 

variable "name" {
  description = "The name of the log analytics workspace"
  type        = string
  default     = ""
}



