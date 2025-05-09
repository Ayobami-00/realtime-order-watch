locals {
  objstore_config = {
    type   = "AZURE"
    config = {
      storage_account = var.storage_account_name
      storage_account_key = var.azure_workload_identity_client_id == null ? var.storage_account_key : null
      container           = var.storage_container_name
      # endpoint            = "" # Optional: Specify if not using default Azure public endpoint
      # max_retries         = 0  # Optional
    }
  }

  common_service_account_config = var.azure_workload_identity_client_id != null ? {
    create      = true # Instruct helm chart to create the service account
    name        = null # Let helm chart use default names like <release>-<component>
    annotations = merge(
      var.service_account_annotations, # Allow passing additional annotations
      {
        "azure.workload.identity/client-id" = var.azure_workload_identity_client_id
      }
    )
  } : {}

  thanos_helm_values = {
    objstoreConfig = yamlencode(local.objstore_config)

    commonLabels = var.additional_labels

    query = {
      enabled      = var.query_enabled
      replicaCount = var.query_replicas
      service = {
        type = var.query_service_type
      }
      resources      = var.resources.query
      serviceAccount = local.common_service_account_config
      # affinity, tolerations, nodeSelector can be added here
    }

    queryFrontend = {
      enabled        = var.query_frontend_enabled
      replicaCount   = var.query_frontend_replicas
      serviceAccount = local.common_service_account_config # Apply to frontend as well
      # resources, affinity etc.
    }

    storegateway = {
      enabled        = var.storegateway_enabled
      replicaCount   = var.storegateway_replicas
      resources      = var.resources.storegateway
      serviceAccount = local.common_service_account_config
      # affinity, tolerations, nodeSelector can be added here
    }

    compactor = {
      enabled                 = var.compactor_enabled
      retentionResolutionRaw  = var.compactor_retention_raw
      retentionResolution5m   = var.compactor_retention_5m
      retentionResolution1h   = var.compactor_retention_1h
      resources               = var.resources.compactor
      serviceAccount          = local.common_service_account_config
      # affinity, tolerations, nodeSelector can be added here
    }

    ruler = {
      enabled        = var.ruler_enabled
      serviceAccount = local.common_service_account_config # Apply to ruler if it needs to access storage
      # Configure rules, alertmanagers, etc. if enabled
    }

    # Disable components not explicitly managed by this central deployment
    # (assuming sidecars/receive are handled elsewhere or not used)
    bucketweb = {
      enabled = false
    }
    receive = {
      enabled = false
    }
    # Adjust based on your exact needs; this example focuses on Query, Store, Compactor
  }
}

resource "helm_release" "thanos" {
  name             = var.release_name
  repository       = var.helm_chart_repository
  chart            = var.helm_chart_name
  version          = var.helm_chart_version
  namespace        = var.kubernetes_namespace
  create_namespace = var.create_namespace
  timeout          = 1800 # 30 minutes
  atomic           = true
  wait             = true

  values = [
    yamlencode(local.thanos_helm_values)
  ]

  # If you need to set specific values that aren't deeply nested or require complex types:
  set {
    name  = "query.dnsDiscovery.sidecarsService"
    value = "prometheus-kube-prometheus-thanos-discovery" # Example if using kube-prometheus-stack's Thanos sidecar discovery
  }
  set {
    name  = "query.dnsDiscovery.sidecarsNamespace"
    value = "monitoring" # Namespace where Prometheus/Thanos sidecars run
  }
}
