# VNet Input Variables

# VPC Name
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

# VPC Tags
variable "vnet_tags" {
  description = "Tags for the VNet"
  type        = map(string)
  default     = {}
}

# VPC CIDR Block
variable "vnet_cidr_block" {
  description = "CIDR block for VNet"
  type        = string
  default     = "10.0.0.0/16"
}

# VPC Public Subnets
variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

# VPC Private Subnets
variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# VPC Database Subnets
variable "database_subnets" {
  description = "List of database subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.151.0/24", "10.0.152.0/24"]
}

# VPC Create Database Subnet Group (True / False)
variable "create_database_subnet_group" {
  description = "Controls if database subnet group should be created"
  type        = bool
  default     = true
}

# VPC Create Database Subnet Route Table (True or False)
variable "create_database_subnet_route_table" {
  description = "Controls if database subnet route table should be created"
  type        = bool
  default     = true
}

# VPC Enable NAT Gateway (True or False) 
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets outbound communication"
  type        = bool
  default     = true
}

# VPC Single NAT Gateway (True or False)
variable "single_nat_gateway" {
  description = "Enable only single NAT Gateway to save costs"
  type        = bool
  default     = true
}

variable "aks_location" {
  description = "Azure region for AKS resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}





