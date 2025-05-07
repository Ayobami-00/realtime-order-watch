resource "azurerm_log_analytics_workspace" "insights" {
  name                = var.name
  location            = var.aks_location
  resource_group_name = var.resource_group_name
  retention_in_days   = var.retention_in_days

  timeouts {
    create = "2h"
    update = "2h"
    delete = "2h"
    read   = "5m"
  }
}
