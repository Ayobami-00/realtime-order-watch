
resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "${var.name}-workspace"
  location            = var.aks_location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "insights" {
  name                = var.name
  location            = var.aks_location
  resource_group_name = var.resource_group_name
  
  application_type = var.application_type

  workspace_id        = azurerm_log_analytics_workspace.workspace.id

  tags = var.tags 
}
