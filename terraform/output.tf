output "resource_group_name" {
  value = data.azurerm_resource_group.resource_group.name
}

output "name" {
  value = azurerm_kubernetes_cluster.sachin-testcluster.name
}
