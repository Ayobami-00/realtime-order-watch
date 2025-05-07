variable "name" {
  description = "The name of the federated identity credential"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}


variable "issuer" {
  description = "The issuer of the federated identity credential"
  type        = string
} 

variable "parent_id" {
  description = "The parent id of the federated identity credential"
  type        = string
}


variable "subject" {
  description = "The subject of the federated identity credential"
  type        = string
}


