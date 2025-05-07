resource "azuread_group" "aks_administrators" {

  display_name     = var.display_name
  security_enabled = var.security_enabled
  description      = var.description
}


