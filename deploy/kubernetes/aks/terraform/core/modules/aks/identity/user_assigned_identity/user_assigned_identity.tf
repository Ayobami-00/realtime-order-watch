resource "azurerm_user_assigned_identity" "dns_manager" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.aks_location
}
