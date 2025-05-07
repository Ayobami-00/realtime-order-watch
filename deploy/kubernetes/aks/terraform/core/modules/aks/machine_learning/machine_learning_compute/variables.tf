variable "name" {
  description = "The name of the machine learning compute"
  type        = string
}


variable "location" {
  description = "The location of the machine learning compute"
  type        = string
}


variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}


variable "machine_learning_workspace_name" {
  description = "The name of the machine learning workspace"
  type        = string
}


variable "machine_learning_workspace_id" {
  description = "The id of the machine learning workspace"
  type        = string
}


variable "compute_type" {
  description = "The type of compute"
  type        = string
}


variable "min_nodes" {
  description = "The minimum number of nodes"
  type        = number
}


variable "max_nodes" {
  description = "The maximum number of nodes"
  type        = number
}


variable "vm_size" {
  description = "The size of the VM"
  type        = string
}


variable "vm_priority" {
  description = "The priority of the VM"
  type        = string
}

variable "scale_down_nodes_after_idle_duration" {
  description = "The duration after which the nodes are scaled down"
  type        = string
}


variable "subnet_id" {
  description = "The id of the subnet"
  type        = string
}

variable "ssh_public_access_enabled" {
  description = "Whether to enable public SSH access to the compute nodes"
  type        = bool
  default     = false
}

variable "ssh_admin_username" {
  description = "The administrator username for SSH access"
  type        = string
  default     = null
}

variable "ssh_admin_password" {
  description = "The administrator password for SSH access"
  type        = string
  default     = null
  sensitive   = true
}

variable "ssh_key_value" {
  description = "The SSH public key for authentication"
  type        = string
  default     = null
}

variable "startup_script" {
  description = "Startup script content to run on each node"
  type        = string
  default     = null
}

variable "huggingface_token" {
  description = "HuggingFace API token"
  type        = string
  default     = null
  sensitive   = true
}

