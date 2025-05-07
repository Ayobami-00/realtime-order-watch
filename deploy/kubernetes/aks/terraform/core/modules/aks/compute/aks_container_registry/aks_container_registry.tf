resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  location            = var.acr_location
  resource_group_name = var.acr_resource_group_name
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled
}