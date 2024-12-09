output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "function_app_url" {
  value = azurerm_linux_function_app.function_app.default_hostname
}

# output "apim_url" {
#   value = azurerm_api_management.apim.gateway_url
# }
