locals {
  is_private = var.access_mode == "private"
}

resource "azurerm_storage_account" "storage_account" {
  name                          = var.storage_account_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_tier                  = var.account_tier
  account_replication_type      = var.account_replication_type
  
  # Security settings - always enable HTTPS and TLS1_2
  https_traffic_only_enabled    = var.enable_https_traffic_only
  min_tls_version              = var.min_tls_version

  # Conditional security settings based on mode
  public_network_access_enabled = local.is_private ? var.public_network_access_enabled : true

  dynamic "network_rules" {
    for_each = local.is_private ? [1] : []
    content {
      default_action             = var.default_action
      ip_rules                   = var.ip_rules
      virtual_network_subnet_ids = var.virtual_network_subnet_ids
      bypass                     = var.bypass
    }
  }
}