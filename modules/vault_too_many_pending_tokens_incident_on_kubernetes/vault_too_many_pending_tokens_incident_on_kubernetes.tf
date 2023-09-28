resource "shoreline_notebook" "vault_too_many_pending_tokens_incident_on_kubernetes" {
  name       = "vault_too_many_pending_tokens_incident_on_kubernetes"
  data       = file("${path.module}/data/vault_too_many_pending_tokens_incident_on_kubernetes.json")
  depends_on = [shoreline_action.invoke_kubectl_describe_pods,shoreline_action.invoke_vault_connections,shoreline_action.invoke_update_rate_limit]
}

resource "shoreline_file" "kubectl_describe_pods" {
  name             = "kubectl_describe_pods"
  input_file       = "${path.module}/data/kubectl_describe_pods.sh"
  md5              = filemd5("${path.module}/data/kubectl_describe_pods.sh")
  description      = "Check the current resource limits and requests for the Vault and Cassandra pods"
  destination_path = "/agent/scripts/kubectl_describe_pods.sh"
  resource_query   = "container | app='shoreline'"
  enabled          = true
}

resource "shoreline_file" "vault_connections" {
  name             = "vault_connections"
  input_file       = "${path.module}/data/vault_connections.sh"
  md5              = filemd5("${path.module}/data/vault_connections.sh")
  description      = "High number of concurrent requests to Vault API that leads to the generation of too many pending tokens."
  destination_path = "/agent/scripts/vault_connections.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "update_rate_limit" {
  name             = "update_rate_limit"
  input_file       = "${path.module}/data/update_rate_limit.sh"
  md5              = filemd5("${path.module}/data/update_rate_limit.sh")
  description      = "Increase the token creation rate limit on Vault to reduce the number of pending tokens."
  destination_path = "/agent/scripts/update_rate_limit.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_kubectl_describe_pods" {
  name        = "invoke_kubectl_describe_pods"
  description = "Check the current resource limits and requests for the Vault and Cassandra pods"
  command     = "`chmod +x /agent/scripts/kubectl_describe_pods.sh && /agent/scripts/kubectl_describe_pods.sh`"
  params      = ["VAULT_POD_NAME","CASSANDRA_POD_NAME","NAMESPACE"]
  file_deps   = ["kubectl_describe_pods"]
  enabled     = true
  depends_on  = [shoreline_file.kubectl_describe_pods]
}

resource "shoreline_action" "invoke_vault_connections" {
  name        = "invoke_vault_connections"
  description = "High number of concurrent requests to Vault API that leads to the generation of too many pending tokens."
  command     = "`chmod +x /agent/scripts/vault_connections.sh && /agent/scripts/vault_connections.sh`"
  params      = ["VAULT_POD_NAME","VAULT_ADDRESS","VAULT_CONTAINER_NAME","MAX_CONNECTIONS","NAMESPACE"]
  file_deps   = ["vault_connections"]
  enabled     = true
  depends_on  = [shoreline_file.vault_connections]
}

resource "shoreline_action" "invoke_update_rate_limit" {
  name        = "invoke_update_rate_limit"
  description = "Increase the token creation rate limit on Vault to reduce the number of pending tokens."
  command     = "`chmod +x /agent/scripts/update_rate_limit.sh && /agent/scripts/update_rate_limit.sh`"
  params      = ["DEPLOYMENT_NAME","NAMESPACE"]
  file_deps   = ["update_rate_limit"]
  enabled     = true
  depends_on  = [shoreline_file.update_rate_limit]
}

