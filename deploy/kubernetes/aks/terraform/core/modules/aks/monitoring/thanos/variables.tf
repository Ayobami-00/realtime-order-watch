variable "kubernetes_namespace" {
  description = "Kubernetes namespace to deploy Thanos components."
  type        = string
  default     = "monitoring"
}

variable "release_name" {
  description = "Helm release name for Thanos."
  type        = string
  default     = "thanos"
}

variable "helm_chart_repository" {
  description = "Repository URL for the Thanos Helm chart."
  type        = string
  default     = "https://charts.bitnami.com/bitnami"
}

variable "helm_chart_name" {
  description = "Name of the Thanos Helm chart."
  type        = string
  default     = "thanos"
}

variable "helm_chart_version" {
  description = "Version of the Thanos Helm chart. Check Bitnami for the latest suitable version."
  type        = string
  default     = "12.17.0" # Example version, corresponds to Thanos app v0.34.0
}

variable "create_namespace" {
  description = "Whether the Helm chart should create the Kubernetes namespace if it doesn't exist."
  type        = bool
  default     = true
}

# --- Object Storage Configuration ---
variable "storage_account_name" {
  description = "Azure Storage Account name for Thanos long-term storage."
  type        = string
}

variable "storage_container_name" {
  description = "Azure Blob Container name for Thanos."
  type        = string
}

variable "storage_account_key" {
  description = "Primary access key for the Azure Storage Account. This is sensitive."
  type        = string
  sensitive   = true
}

# --- Thanos Component Configuration ---
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
  description = "Kubernetes service type for Thanos Query."
  type        = string
  default     = "ClusterIP" # Change to LoadBalancer or NodePort if external access is needed directly
}

variable "query_frontend_enabled" {
  description = "Enable Thanos Query Frontend component."
  type        = bool
  default     = true # Often recommended for better query experience
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
  description = "Compactor retention for raw metrics."
  type        = string
  default     = "30d"
}

variable "compactor_retention_5m" {
  description = "Compactor retention for 5m downsampled metrics."
  type        = string
  default     = "90d"
}

variable "compactor_retention_1h" {
  description = "Compactor retention for 1h downsampled metrics."
  type        = string
  default     = "1y"
}

variable "ruler_enabled" {
  description = "Enable Thanos Ruler component."
  type        = bool
  default     = false # Enable if you need global rules/alerting
}

variable "additional_labels" {
  description = "Additional labels to apply to all Thanos components."
  type        = map(string)
  default     = {}
}

variable "resources" {
  description = "Default resource requests and limits for Thanos components."
  type = object({
    query = object({
      requests = object({ cpu = string, memory = string })
      limits   = object({ cpu = string, memory = string })
    })
    storegateway = object({
      requests = object({ cpu = string, memory = string })
      limits   = object({ cpu = string, memory = string })
    })
    compactor = object({
      requests = object({ cpu = string, memory = string })
      limits   = object({ cpu = string, memory = string })
    })
    # Add other components as needed
  })
  default = {
    query = {
      requests = { cpu = "250m", memory = "512Mi" }
      limits   = { cpu = "1", memory = "1Gi" }
    }
    storegateway = {
      requests = { cpu = "250m", memory = "512Mi" }
      limits   = { cpu = "1", memory = "1Gi" }
    }
    compactor = {
      requests = { cpu = "250m", memory = "512Mi" }
      limits   = { cpu = "1", memory = "1Gi" }
    }
  }
}
