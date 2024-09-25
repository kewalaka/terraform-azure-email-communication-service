# register the Communication resource provider
resource "azapi_resource_action" "communication_resource_provider" {
  type        = "Microsoft.Resources/subscriptions@2021-04-01"
  resource_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  action      = "providers/Microsoft.Communication/register"
  method      = "POST"
}

# unregisters the Communication resource provider
resource "azapi_resource_action" "communication_resource_provider_unregister" {
  type        = "Microsoft.Resources/subscriptions@2021-04-01"
  resource_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  action      = "providers/Microsoft.Communication/unregister"
  method      = "POST"
  when        = "destroy"
}
