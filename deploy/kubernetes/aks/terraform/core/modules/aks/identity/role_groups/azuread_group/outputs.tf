output "azuread_group_id" {
  value = azuread_group.aks_administrators.id
}

output "azuread_group_name" {
  value = azuread_group.aks_administrators.display_name
}


output "azuread_group_object_id" {
  value = azuread_group.aks_administrators.object_id
}





