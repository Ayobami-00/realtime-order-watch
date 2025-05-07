terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10"
    }

   kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }

  }

  backend "azurerm" {
    key = "dev.terraform.tfstate"
  }

}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = false
    }
  }
}

data "azurerm_kubernetes_cluster" "aks" {
  count               = var.deployment_stage == 1 ? 1 : 0
  name                = var.aks_cluster_name
  resource_group_name = var.aks_resource_group_name
}

provider "kubernetes" {
  host                   = var.deployment_stage == 1 ? data.azurerm_kubernetes_cluster.aks[0].kube_admin_config.0.host : null
  client_certificate     = var.deployment_stage == 1 ? base64decode(data.azurerm_kubernetes_cluster.aks[0].kube_admin_config.0.client_certificate) : null
  client_key             = var.deployment_stage == 1 ? base64decode(data.azurerm_kubernetes_cluster.aks[0].kube_admin_config.0.client_key) : null
  cluster_ca_certificate = var.deployment_stage == 1 ? base64decode(data.azurerm_kubernetes_cluster.aks[0].kube_admin_config.0.cluster_ca_certificate) : null
}

provider "helm" {
  kubernetes {
  host                   = var.deployment_stage == 1 ? data.azurerm_kubernetes_cluster.aks[0].kube_admin_config.0.host : null
  client_certificate     = var.deployment_stage == 1 ? base64decode(data.azurerm_kubernetes_cluster.aks[0].kube_admin_config.0.client_certificate) : null
  client_key             = var.deployment_stage == 1 ? base64decode(data.azurerm_kubernetes_cluster.aks[0].kube_admin_config.0.client_key) : null
  cluster_ca_certificate = var.deployment_stage == 1 ? base64decode(data.azurerm_kubernetes_cluster.aks[0].kube_admin_config.0.cluster_ca_certificate) : null
}
}

provider "kubectl" {
  load_config_file       = false
  host                   = var.deployment_stage == 1 ? data.azurerm_kubernetes_cluster.aks[0].kube_admin_config.0.host : null
  client_certificate     = var.deployment_stage == 1 ? base64decode(data.azurerm_kubernetes_cluster.aks[0].kube_admin_config.0.client_certificate) : null
  client_key             = var.deployment_stage == 1 ? base64decode(data.azurerm_kubernetes_cluster.aks[0].kube_admin_config.0.client_key) : null
  cluster_ca_certificate = var.deployment_stage == 1 ? base64decode(data.azurerm_kubernetes_cluster.aks[0].kube_admin_config.0.cluster_ca_certificate) : null
}