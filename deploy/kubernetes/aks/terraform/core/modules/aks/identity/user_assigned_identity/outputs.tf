
output "user_assigned_identity_id" {
  value = azurerm_user_assigned_identity.dns_manager.id
}


output "user_assigned_identity_principal_id" {
  value = azurerm_user_assigned_identity.dns_manager.principal_id
}


output "user_assigned_identity_client_id" {
  value = azurerm_user_assigned_identity.dns_manager.client_id
}

