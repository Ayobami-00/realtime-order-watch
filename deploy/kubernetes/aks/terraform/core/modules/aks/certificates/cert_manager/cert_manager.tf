# resource "kubernetes_namespace" "cert_manager" {
#   metadata {
#     name = var.cert_manager_namespace  
#   }
# }

resource "helm_release" "cert_manager" {
  namespace  = var.cert_manager_namespace 
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.14.2" # app version 1.14.2
  values = [yamlencode({
    # NB installCRDs is generally not recommended, BUT since this
    #    is a development cluster we YOLO it.
    installCRDs = true
    podLabels = {
      "azure.workload.identity/use" = "true"
    }
    serviceAccount = {
      name = "cert-manager"
    }
  })]
}


resource "kubectl_manifest" "cert_manager_ingress" {
  depends_on = [
    helm_release.cert_manager
  ]
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      namespace = var.cert_manager_namespace
      name      = var.cluster_issuer_name 
    }
    spec = {
      acme = {
        server = var.letsencrypt_server
        email  = var.letsencrypt_email
        privateKeySecretRef = {
          name = "tls-secret"
        }
        solvers = [{
          selector = {
            dnsZones = [
              var.dns_zone 
            ]
          }
          dns01 = {
            azureDNS = {
              subscriptionID    = var.azure_subscription_id
              resourceGroupName = var.resource_group_name
              hostedZoneName    = var.dns_zone
              managedIdentity = {
                clientID = var.cert_manager_client_id
              }
            }
          }
          # http01 = {
          #   ingress = {
          #     class = "nginx"
          #   }
          # }
        }]
      }
    }
  })
}