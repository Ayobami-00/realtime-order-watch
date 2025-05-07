# VPC Tags
variable "host" {
  description = "SSH Host"
}

variable "user" {
  description = "SSH User"
}


variable "private_key" {
  description = "SSH Private Key"
}

# variable "private_key_path" {
#   description = "SSH Private Key Path"
# }

# variable "private_key_name" {
#   description = "SSH Private Key Name"
# }

variable "input_file_source" {
  description = ""
}

variable "destination_file_path" {
  description = ""
}

variable "commands_to_execute" {
  description = "SSH Command to Execute"
  type = list(string)
}