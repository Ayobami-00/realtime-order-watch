data "kubectl_file_documents" "clusterissuer" {
  content = file(templatefile("${path.module}/clusterissuer-nginx.yaml", {
    cert_manager_email = var.cert_manager_email
  }))
}

resource "kubectl_manifest" "clusterissuer" {
  for_each  = data.kubectl_file_documents.clusterissuer.manifests
  yaml_body = each.value
  depends_on = [
    data.kubectl_file_documents.clusterissuer
  ]
}
