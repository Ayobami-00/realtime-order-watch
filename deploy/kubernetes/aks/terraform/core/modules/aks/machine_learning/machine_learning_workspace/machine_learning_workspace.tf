resource "azurerm_machine_learning_workspace" "machine_learning_workspace" {
  name = var.name

  location            = var.location
  resource_group_name = var.resource_group_name

  application_insights_id       = var.application_insights_id
  container_registry_id         = var.container_registry_id
  key_vault_id                  = var.key_vault_id
  storage_account_id            = var.storage_account_id
  public_network_access_enabled = var.public_network_access_enabled

  identity {
    type = var.identity_type
  }

  tags = var.tags 
}