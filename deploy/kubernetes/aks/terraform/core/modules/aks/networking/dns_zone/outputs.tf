
# DNS Zone ID
output "dns_zone_id" {
  value = azurerm_dns_zone.dns_zone.id
}

# DNS Zone Name
output "dns_zone_name" {
  value = azurerm_dns_zone.dns_zone.name
}

