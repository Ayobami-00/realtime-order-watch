variable "kubernetes_namespace" {
  description = "The Kubernetes namespace where Thanos will be deployed."
  type        = string
  default     = "monitoring"
}

variable "release_name" {
  description = "The Helm release name for Thanos."
  type        = string
  default     = "thanos"
}

variable "helm_chart_repository" {
  description = "The repository URL for the Thanos Helm chart."
  type        = string
  default     = "https://charts.bitnami.com/bitnami"
}

variable "helm_chart_name" {
  description = "The name of the Thanos Helm chart."
  type        = string
  default     = "thanos"
}

variable "helm_chart_version" {
  description = "The version of the Thanos Helm chart."
  type        = string
  default     = "12.18.0" # Check for the latest stable version compatible with your needs
}

variable "create_namespace" {
  description = "Whether to create the Kubernetes namespace if it doesn't exist."
  type        = bool
  default     = true
}

# --- Object Storage Configuration ---
variable "storage_account_name" {
  description = "The name of the Azure Storage Account."
  type        = string
}

variable "storage_container_name" {
  description = "The name of the Azure Blob Storage container."
  type        = string
}

variable "storage_account_key" {
  description = "The primary access key for the Azure Storage Account. Optional if using Azure AD Workload Identity."
  type        = string
  sensitive   = true
  default     = null # Make it optional
}

# --- Thanos Component Configuration ---
variable "additional_labels" {
  description = "Additional labels to apply to all Thanos components."
  type        = map(string)
  default     = {}
}

variable "query_enabled" {
  description = "Enable Thanos Query component."
  type        = bool
  default     = true
}

variable "query_replicas" {
  description = "Number of replicas for Thanos Query."
  type        = number
  default     = 1
}

variable "query_service_type" {
  description = "Service type for Thanos Query."
  type        = string
  default     = "ClusterIP"
}

variable "query_frontend_enabled" {
  description = "Enable Thanos Query Frontend component."
  type        = bool
  default     = false # Often deployed separately or not needed for basic setups
}

variable "query_frontend_replicas" {
  description = "Number of replicas for Thanos Query Frontend."
  type        = number
  default     = 1
}

variable "storegateway_enabled" {
  description = "Enable Thanos StoreGateway component."
  type        = bool
  default     = true
}

variable "storegateway_replicas" {
  description = "Number of replicas for Thanos StoreGateway."
  type        = number
  default     = 1
}

variable "compactor_enabled" {
  description = "Enable Thanos Compactor component."
  type        = bool
  default     = true
}

variable "compactor_retention_raw" {
  description = "Retention period for raw blocks in compactor."
  type        = string
  default     = "30d" # Example: 30 days
}

variable "compactor_retention_5m" {
  description = "Retention period for 5m downsampled blocks in compactor."
  type        = string
  default     = "90d" # Example: 90 days
}

variable "compactor_retention_1h" {
  description = "Retention period for 1h downsampled blocks in compactor."
  type        = string
  default     = "365d" # Example: 1 year
}

variable "ruler_enabled" {
  description = "Enable Thanos Ruler component."
  type        = bool
  default     = false
}

# You might want to add more specific variables for Ruler configuration if enabled

variable "resources" {
  description = "Resource requests and limits for Thanos components (query, storegateway, compactor)."
  type = object({
    query = optional(object({
      requests = optional(object({ cpu = optional(string, "250m"), memory = optional(string, "512Mi") }))
      limits   = optional(object({ cpu = optional(string, "1"), memory = optional(string, "1Gi") }))
    }), {})
    storegateway = optional(object({
      requests = optional(object({ cpu = optional(string, "250m"), memory = optional(string, "512Mi") }))
      limits   = optional(object({ cpu = optional(string, "1"), memory = optional(string, "1Gi") }))
    }), {})
    compactor = optional(object({
      requests = optional(object({ cpu = optional(string, "250m"), memory = optional(string, "512Mi") }))
      limits   = optional(object({ cpu = optional(string, "1"), memory = optional(string, "2Gi") })) # Compactor can be memory intensive
    }), {})
  })
  default = {}
}

variable "azure_workload_identity_client_id" {
  description = "The client ID of the Azure User Assigned Identity to be used for Workload Identity."
  type        = string
  default     = null
}

variable "service_account_annotations" {
  description = "Annotations to add to the service accounts created for Thanos components."
  type        = map(string)
  default     = {}
}
