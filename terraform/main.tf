resource "azurerm_resource_group" "rg" {
  name     = "rust-trigger-rg"
  location = "westeurope"
}

resource "azurerm_storage_account" "storage" {
  name                     = "storage4rstrigger"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "asp" {
  name                = "rust-trigger-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  # reserved            = true
  os_type  = "Linux"
  sku_name = "B1"
  # sku {
  #   tier = "Consumption"
  #   size = "B1"
  # }
}

resource "azurerm_linux_function_app" "function_app" {
  name                       = "rust-trigger"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  service_plan_id            = azurerm_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  https_only                 = true
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "custom"
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }
  site_config {
    application_stack {
      use_custom_runtime          = true
    }
  }
}

# resource "azurerm_api_management" "apim" {
#   name                = "rust-trigger-api-mngmt"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   publisher_email     = "newtonchutney@example.com"
#   publisher_name      = "API Admin"
#   sku_name            = "Developer_1"
# }

# resource "azurerm_api_management_api" "api" {
#   name                = "AzureApimAPI"
#   resource_group_name = azurerm_resource_group.rg.name
#   api_management_name = azurerm_api_management.apim.name
#   revision            = "1"
#   display_name        = "Rust Trigger API"
#   path                = "rust-trigger-mgnmt"
#   protocols           = ["https"]
#   service_url         = "https://${azurerm_linux_function_app.function_app.default_hostname}"
# }

# # APIM Security: Add API Key Policy
# resource "azurerm_api_management_api_operation" "api_operation" {
#   operation_id        = "get-default"
#   api_name            = azurerm_api_management_api.api.name
#   api_management_name = azurerm_api_management.apim.name
#   resource_group_name = azurerm_resource_group.rg.name
#   display_name        = "Default"
#   method              = "GET"
#   url_template        = "/"
# }

# resource "azurerm_api_management_api_policy" "api_policy" {
#   api_name            = azurerm_api_management_api.api.name
#   api_management_name = azurerm_api_management.apim.name
#   resource_group_name = azurerm_resource_group.rg.name

#   xml_content = <<EOT
#     <policies>
#       <inbound>
#         <base />
#         <set-header name="X-Frame-Options" exists-action="override">
#           <value>Deny</value>
#         </set-header>
#         <validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized">
#           <openid-config url="https://login.microsoftonline.com/{tenantId}/v2.0/.well-known/openid-configuration" />
#           <required-claims>
#             <claim name="aud">
#               <value>api://your-api-client-id</value>
#             </claim>
#           </required-claims>
#         </validate-jwt>
#       </inbound>
#       <backend>
#         <base />
#       </backend>
#       <outbound>
#         <base />
#       </outbound>
#     </policies>
#   EOT
# }
