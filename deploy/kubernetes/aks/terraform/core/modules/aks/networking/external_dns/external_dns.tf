resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = var.external_dns_namespace
  }
}

resource "helm_release" "external_dns" {
  namespace  = var.external_dns_namespace 
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "6.32.1" # app version 0.14.0
  values = [yamlencode({
    policy     = "sync"
    txtOwnerId = var.resource_group_name
    sources = [
      "ingress"
    ]
    domainFilters = [
      var.dns_zone
    ]
    provider = "azure"
    podLabels = {
      "azure.workload.identity/use" = "true"
    }
    serviceAccount = {
      name = "external-dns"
      annotations = {
        "azure.workload.identity/client-id" = var.external_dns_client_id
      }
    }
    azure = {
      tenantId                     = var.aks_tenant_id
      subscriptionId               = var.azure_subscription_id
      resourceGroup                = var.resource_group_name
      useWorkloadIdentityExtension = true
    }
  })]
}