
output "private_key" {
  value = tls_private_key.tls_private_key.private_key_pem
}

output "key_id" {
  value = tls_private_key.tls_private_key.id
}

output "public_key" {
  value = tls_private_key.tls_private_key.public_key_openssh
}

