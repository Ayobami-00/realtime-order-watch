
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

variable "tags" {
  description = "The tags to apply to the application insights"
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "The name of the application insights"
  type        = string
  default     = ""
}

variable "application_type" {
  description = "The type of application"
  type        = string
}





