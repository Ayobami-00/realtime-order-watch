variable "application_name" {
  description = "Name of the Application"
  type        = string
}

variable "application_tags" {
  description = "Tags of the Application"
}

variable "application_replicas" {
  type = number
}

variable "application_image" {
  type = string
}

variable "application_port" {
  type = number
}

variable "application_envs" {
}

variable "application_service_type" {
  type = string
}

variable "create_pvc" {
  type    = bool
  default = false
}

variable "application_pvc_storage_class_name" {
  type    = string
  default = ""
}

variable "application_pvc_storage_amount" {
  type    = string
  default = "4Gi"
}

variable "create_volume" {
  type    = bool
  default = false
}

variable "application_volume_mount_path" {
  type    = string
  default = ""
}