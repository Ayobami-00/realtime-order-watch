variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = ""
}

variable "company_name" {
  description = "Company Name"
  type        = string
  default     = ""
}


variable "is_company_deployed" {
  type    = bool
  default = false
}

variable "subscription_id" {
  description = "Azure Subscription Id"
  type        = string
  default     = ""
}


variable "aks_resource_group_name" {
  description = "AKS Resource Group Name"
  type        = string
  default     = ""
}

variable "aks_location" {
  description = "AKS Location"
  type        = string
  default     = ""
}


variable "aks_cluster_name" {
  description = "AKS Cluster Name"
  type        = string
  default     = ""
}




variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
  default     = ""
}


variable "storage_container_name" {
  description = "The name of the storage container"
  type        = string
  default     = ""
}


variable "deployment_stage" {
  description = "The stage of the deployment"
  type        = number
  default     = 0
}


variable "github_token" {
  description = "GitHub Token"
  type        = string
  default     = ""
}
