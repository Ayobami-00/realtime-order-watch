# VNet Output Values

# VNet ID
output "vnet_id" {
  description = "The ID of the VNet"
  value       = azurerm_virtual_network.vnet.id
}

# VNet CIDR blocks
output "vnet_cidr_block" {
  description = "The CIDR block of the VNet"
  value       = one(azurerm_virtual_network.vnet.address_space)
}

# VNet Private Subnets
output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = azurerm_subnet.private[*].id
}

# VNet Public Subnets
output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = azurerm_subnet.public[*].id
}

# NAT Gateway Public IP
output "nat_public_ip" {
  description = "The Public IP address of the NAT Gateway"
  value       = var.enable_nat_gateway ? azurerm_public_ip.nat[0].ip_address : null
}

# VNet Location (equivalent to AWS AZs)
output "aks_location" {
  description = "The Azure region where the VNet is created"
  value       = azurerm_virtual_network.vnet.location
}

# Resource Group Name
output "resource_group_name" {
  description = "The name of the resource group where the VNet is created"
  value       = azurerm_virtual_network.vnet.resource_group_name
}