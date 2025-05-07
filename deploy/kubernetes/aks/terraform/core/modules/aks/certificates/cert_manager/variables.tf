variable "cert_manager_namespace" {
    description = "The namespace to deploy the cert-manager to"
    type        = string
    default     = "cert-manager"
  }

variable "dns_zone" {
  description = "The zone to deploy the cert-manager to"
  type        = string
}

variable "resource_group_name" {
  description = "The resource group name"
  type        = string
}


variable "azure_subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}


variable "cert_manager_client_id" {
  description = "The cert-manager client ID"
  type        = string
}


variable "letsencrypt_server" {
  description = "The Let's Encrypt server"
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "letsencrypt_email" {
  description = "The Let's Encrypt email"
  type        = string
}



variable "cluster_issuer_name" {
  description = "The name of the cluster issuer"
  type        = string
}


