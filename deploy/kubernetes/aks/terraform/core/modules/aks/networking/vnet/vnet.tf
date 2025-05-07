# Create Azure Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.aks_location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_cidr_block]
  
  # VNet DNS Settings
  dns_servers = ["168.63.129.16"] # Azure default DNS
  
  tags = var.vnet_tags
}

# Public Subnets
resource "azurerm_subnet" "public" {
  count                = length(var.public_subnets)
  name                 = "public-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.public_subnets[count.index]]

  service_endpoints = ["Microsoft.ContainerRegistry"]
}

# Private Subnets
resource "azurerm_subnet" "private" {
  count                = length(var.private_subnets)
  name                 = "private-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_subnets[count.index]]

  service_endpoints = ["Microsoft.ContainerRegistry", "Microsoft.Storage"]
}

# Database Subnets
resource "azurerm_subnet" "database" {
  count                = length(var.database_subnets)
  name                 = "database-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.database_subnets[count.index]]

  service_endpoints = ["Microsoft.Sql"]
}

# NAT Gateway for private subnets (equivalent to AWS NAT Gateway)
resource "azurerm_nat_gateway" "nat" {
  count               = var.enable_nat_gateway ? 1 : 0
  name                = "${var.vnet_name}-natgw"
  location            = var.aks_location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
}

# Public IP for NAT Gateway
resource "azurerm_public_ip" "nat" {
  count               = var.enable_nat_gateway ? 1 : 0
  name                = "${var.vnet_name}-natgw-ip"
  location            = var.aks_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Associate NAT Gateway with public IP
resource "azurerm_nat_gateway_public_ip_association" "nat" {
  count                = var.enable_nat_gateway ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.nat[0].id
  public_ip_address_id = azurerm_public_ip.nat[0].id
}

# Add AKS-specific tags to subnets
locals {
  subnet_tags = {
    "kubernetes.io/cluster/${var.vnet_name}" = "shared"
  }
}