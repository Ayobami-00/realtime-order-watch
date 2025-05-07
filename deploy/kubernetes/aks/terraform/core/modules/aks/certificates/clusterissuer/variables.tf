variable "namespace" {
  description = "The namespace to deploy the cert-manager to"
  type        = string
  default     = "cert-manager"
}

variable "cert_manager_email" {
  description = "The email address to use for the cert-manager"
  type        = string
}
