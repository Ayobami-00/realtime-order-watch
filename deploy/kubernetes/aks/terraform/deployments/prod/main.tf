locals {
  company_name            = var.company_name
  aks_resource_group_name = var.aks_resource_group_name
  aks_location            = var.aks_location
  vpc_name                = "${local.company_name}-vpc"
  common_tags = {
    owner       = var.company_name
    environment = local.environment
  }
  vnet_name              = "${var.company_name}-${local.environment}-vnet"
  dns_zone_name          = "enfinitylabs.dev"
  ingress_name           = "ingress"
  ingress_namespace      = "default"
  cert_manager_namespace = "default"
  external_dns_namespace = "external-dns"
  deployment_stage       = var.deployment_stage
  cluster_issuer_name    = "letsencrypt"
  github_token           = var.github_token
}

## ALREADY CREATED FROM PREVIOUS STEPS

# module "aks_resource_group" {
#   source                  = "../../core/modules/aks/compute/aks_resource_group"
#   aks_resource_group_name = local.aks_resource_group_name
#   aks_location            = local.aks_location
# }


module "vnet" {
  source = "../../core/modules/aks/networking/vnet"

  vnet_name           = local.vnet_name
  resource_group_name = local.aks_resource_group_name
  aks_location        = local.aks_location

  # Optional - will use defaults if not specified
  vnet_cidr_block  = "10.0.0.0/16"
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  database_subnets = ["10.0.151.0/24", "10.0.152.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  vnet_tags = local.common_tags
}


module "log_analytics_workspace" {
  source = "../../core/modules/aks/analytics/log_analytics_workspace"

  name                = "${local.company_name}-${local.environment}-log-analytics-workspace"
  aks_location        = local.aks_location
  resource_group_name = local.aks_resource_group_name
  retention_in_days   = 30

}


module "azuread_group" {
  source = "../../core/modules/aks/identity/role_groups/azuread_group"

  display_name     = "${local.company_name}-${local.environment}-cluster-administrators"
  security_enabled = true
  description      = "Azure AKS Kubernetes administrators for the ${local.company_name}-${local.environment}-cluster."
}

module "key_vault" {
  source = "../../core/modules/aks/keys/key_vault"

  name                       = "${local.company_name}-${local.environment}-key-vault"
  resource_group_name        = local.aks_resource_group_name
  aks_location               = local.aks_location
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  sku_name                   = "standard"
}



module "ssh_key" {
  source    = "../../core/modules/aks/keys/ssh_key"
  algorithm = "RSA"
}


module "vault_secret" {
  source       = "../../core/modules/aks/keys/vault_secret"
  name         = "ssh-key"
  value        = module.ssh_key.private_key
  key_vault_id = module.key_vault.key_vault_id
}


module "aks_container_registry" {
  source = "../../core/modules/aks/compute/aks_container_registry"

  acr_name                = "${local.company_name}${local.environment}acr"
  acr_resource_group_name = local.aks_resource_group_name
  acr_location            = local.aks_location
  acr_sku                 = "Standard"
  acr_admin_enabled       = false
}


module "aks_cluster" {
  source = "../../core/modules/aks/compute/aks_cluster"

  name                              = "${local.company_name}-${local.environment}-aks-cluster"
  aks_location                      = local.aks_location
  resource_group_name               = local.aks_resource_group_name
  dns_prefix                        = "${local.company_name}-${local.environment}-aks-cluster"
  node_resource_group_name          = "${local.company_name}-${local.environment}-aks-cluster-rg"
  default_node_pool_name            = "${local.company_name}apl"
  default_node_pool_vm_size         = "Standard_D4s_v3"
  default_node_pool_min_count       = 3
  default_node_pool_max_count       = 5
  default_node_pool_os_disk_size_gb = 30
  default_node_pool_vnet_subnet_id  = module.vnet.private_subnet_ids[0]
  default_node_pool_node_labels = {
    "node_type" = "shared"
    "node_app"  = "adminapps"
  }
  default_node_pool_tags     = local.common_tags
  identity_type              = "SystemAssigned"
  log_analytics_workspace_id = module.log_analytics_workspace.log_analytics_workspace_id
  admin_group_object_ids     = [module.azuread_group.azuread_group_object_id]
  ssh_key                    = module.ssh_key.public_key
  network_plugin             = "azure"
  load_balancer_sku          = "standard"
  tags                       = local.common_tags
  service_cidr               = "172.16.0.0/16"
  dns_service_ip             = "172.16.0.10"
  oidc_issuer_enabled        = true
  workload_identity_enabled  = true
}


module "user_assigned_identity" {
  source = "../../core/modules/aks/identity/user_assigned_identity"

  name                = "external-dns"
  resource_group_name = local.aks_resource_group_name
  aks_location        = local.aks_location

}

module "user_assigned_identity_external_dns" {
  source = "../../core/modules/aks/identity/user_assigned_identity"

  name                = "external-dns"
  resource_group_name = local.aks_resource_group_name
  aks_location        = local.aks_location

}

module "user_assigned_identity_cert_manager" {
  source = "../../core/modules/aks/identity/user_assigned_identity"

  name                = "cert-manager"
  resource_group_name = local.aks_resource_group_name
  aks_location        = local.aks_location

}


# Create role assignment for AKS to pull from ACR
module "role_assignment_acr_pull" {
  source = "../../core/modules/aks/identity/roles/role_assignment"

  scope_id             = module.aks_container_registry.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks_cluster.kubelet_identity[0].object_id
}

module "role_assignment_acr_push" {
  source = "../../core/modules/aks/identity/roles/role_assignment"

  scope_id             = module.aks_container_registry.acr_id
  role_definition_name = "AcrPush"
  principal_id         = module.aks_cluster.kubelet_identity[0].object_id
}

module "github_actions_identity" {
  source = "../../core/modules/aks/identity/user_assigned_identity"

  name                = "${local.company_name}-${local.environment}-github-actions-identity"
  resource_group_name = local.aks_resource_group_name
  aks_location        = local.aks_location
}

module "federated_identity_credential_realtime_order_watch_services" { 
  source = "../../core/modules/aks/identity/federated_identity_credential"

  name                = "github-actions-realtime-order-watch-services"
  resource_group_name = local.aks_resource_group_name
  issuer              = "https://token.actions.githubusercontent.com"
  subject             = "repo:Ayobami-00/realtime-order-watch:ref:refs/heads/main"
  parent_id           = module.github_actions_identity.user_assigned_identity_id

}

module "role_assignment_github_actions_acr_pull" {
  source = "../../core/modules/aks/identity/roles/role_assignment"

  scope_id             = module.aks_container_registry.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.github_actions_identity.user_assigned_identity_principal_id
}

module "role_assignment_github_actions_acr_push" {
  source = "../../core/modules/aks/identity/roles/role_assignment"

  scope_id             = module.aks_container_registry.acr_id
  role_definition_name = "AcrPush"
  principal_id         = module.github_actions_identity.user_assigned_identity_principal_id
}

module "role_assignment_github_actions_aks_admin" {
  source = "../../core/modules/aks/identity/roles/role_assignment"

  scope_id             = module.aks_cluster.aks_cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = module.github_actions_identity.user_assigned_identity_principal_id
}



module "dns_zone" {
  source              = "../../core/modules/aks/networking/dns_zone"
  resource_group_name = local.aks_resource_group_name
  dns_zone_name       = local.dns_zone_name
}



module "federated_identity_credential_external_dns" {
  source = "../../core/modules/aks/identity/federated_identity_credential"

  name                = "external-dns"
  resource_group_name = local.aks_resource_group_name
  issuer              = module.aks_cluster.oidc_issuer_url
  parent_id           = module.user_assigned_identity_external_dns.user_assigned_identity_id
  subject             = "system:serviceaccount:${local.external_dns_namespace}:external-dns"
}

module "federated_identity_credential_cert_manager" {
  source = "../../core/modules/aks/identity/federated_identity_credential"

  name                = "cert-manager"
  resource_group_name = local.aks_resource_group_name
  issuer              = module.aks_cluster.oidc_issuer_url
  parent_id           = module.user_assigned_identity_cert_manager.user_assigned_identity_id
  subject             = "system:serviceaccount:${local.cert_manager_namespace}:cert-manager"
}

module "role_assignment_external_dns" {
  source = "../../core/modules/aks/identity/roles/role_assignment"

  scope_id             = module.dns_zone.dns_zone_id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = module.user_assigned_identity_external_dns.user_assigned_identity_principal_id
}

module "role_assignment_cert_manager" {
  source = "../../core/modules/aks/identity/roles/role_assignment"

  scope_id             = module.dns_zone.dns_zone_id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = module.user_assigned_identity_cert_manager.user_assigned_identity_principal_id
}

data "azurerm_resource_group" "aks" {
  name = local.aks_resource_group_name
}

module "role_assignment_aks_cluster" {
  source               = "../../core/modules/aks/identity/roles/role_assignment"
  scope_id             = data.azurerm_resource_group.aks.id
  role_definition_name = "Reader"
  principal_id         = module.user_assigned_identity.user_assigned_identity_principal_id
}

data "azurerm_subscription" "current" {}

resource "null_resource" "trigger_vectorpath_admin_api_service_github_actions_deployment" {
  triggers = {
    always_run = "${timestamp()}" # This ensures the resource is triggered on every apply
  }
  provisioner "local-exec" {
    command = <<-EOT
      curl --location 'https://api.github.com/repos/Ayobami-00/realtime-order-watch/actions/workflows/production.yml/dispatches' \
      --header 'Accept: application/vnd.github+json' \
      --header 'Authorization: Bearer ${local.github_token}' \
      --header 'X-GitHub-Api-Version: 2022-11-28' \
      --header 'Content-Type: application/json' \
      --data '{
          "ref":"main",
          "inputs":{
            "AZURE_CLIENT_ID":"${module.github_actions_identity.user_assigned_identity_client_id}", 
            "AZURE_TENANT_ID":"${data.azurerm_subscription.current.tenant_id}", 
            "AZURE_SUBSCRIPTION_ID": "${data.azurerm_subscription.current.subscription_id}",  
            "AKS_RESOURCE_GROUP": "${local.aks_resource_group_name}",
            "AKS_CLUSTER_NAME": "${module.aks_cluster.aks_cluster_name}",
            "ACR_REGISTRY":"${module.aks_container_registry.acr_login_server}",
            "ACR_REPOSITORY": "realtime-order-watch-images", 
            "REPLICAS": "1"
          }
        }' 
    EOT
  }
}


# data "azurerm_user_assigned_identity" "existing_user_assigned_identity" {
#   count               = local.deployment_stage == 1 ? 1 : 0
#   name                = "${local.company_name}-${local.environment}-github-actions-identity"
#   resource_group_name = local.aks_resource_group_name
# }
