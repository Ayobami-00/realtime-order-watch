resource "azurerm_federated_identity_credential" "default" {
  name                = var.name
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.issuer
  parent_id           = var.parent_id
  subject             = var.subject
}