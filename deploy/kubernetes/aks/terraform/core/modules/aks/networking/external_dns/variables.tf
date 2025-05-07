variable "external_dns_namespace" {
  description = "The namespace to deploy the external-dns to"
  type        = string
}


variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}


variable "azure_subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}


variable "aks_tenant_id" {
  description = "The AKS tenant ID"
  type        = string
}


variable "external_dns_client_id" {
  description = "The external DNS client ID"
  type        = string
}



variable "dns_zone" {
  description = "The DNS zone to deploy the ingress controller to"
  type        = string
}




