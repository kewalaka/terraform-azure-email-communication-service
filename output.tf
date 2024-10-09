output "azure_tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "azuread_application_client_id" {
  value = azuread_application.email_service_app.client_id
}

output "email_service_app_secret" {
  value     = azuread_application_password.email_service_app_secret.value
  sensitive = true
}

output "communication_service_resource_name" {
  value = azurerm_communication_service.this.name
}
