
output "machine_learning_workspace_id" {
  value = azurerm_machine_learning_workspace.machine_learning_workspace.id
}

output "machine_learning_workspace_name" {
  value = azurerm_machine_learning_workspace.machine_learning_workspace.name
}

output "principal_id" {
  value = azurerm_machine_learning_workspace.machine_learning_workspace.identity[0].principal_id
}