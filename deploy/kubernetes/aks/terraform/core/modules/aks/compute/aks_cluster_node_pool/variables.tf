variable "aks_location" {
  description = "The location of the AKS cluster"
  type        = string
}


variable "auto_scaling_enabled" {
  description = "Enable auto scaling for the node pool"
  type        = bool
}

variable "kubernetes_cluster_id" {
  description = "The ID of the AKS cluster"
  type        = string
}


variable "name" {
  description = "The name of the node pool"
  type        = string
}



variable "min_count" {
  description = "The minimum number of nodes in the node pool"
  type        = number
}



variable "max_count" {
  description = "The maximum number of nodes in the node pool"
  type        = number
}



variable "mode" {
  description = "The mode of the node pool"
  type        = string
  default     = "User"
}



variable "priority" {
  description = "The priority of the node pool"
  type        = string
  default     = "Regular"
}


variable "os_type" {
  description = "The type of the node pool"
  type        = string
  default     = "Linux"
}


variable "vm_size" {
  description = "The size of the node pool"
  type        = string
  default     = "Standard_DS2_v2"
}


variable "vnet_subnet_id" {
  description = "The ID of the subnet"
  type        = string
}


variable "node_labels" {
  description = "The labels of the node pool"
  type        = map(string)
}


variable "tags" {
  description = "The tags of the node pool"
  type        = map(string)
}


variable "os_disk_size_gb" {
  description = "The size of the OS disk"
  type        = number
  default     = 30
}

