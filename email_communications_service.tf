# a random prefix for the names
resource "random_pet" "pet" {}

# somewhere to put the resources
resource "azurerm_resource_group" "this" {
  location = "AustraliaEast"
  name     = "rg-emailsvc-auea-${random_pet.pet.id}"
}

# create the email communication service
module "email_communication_services" {
  source        = "git::https://github.com/Azure/terraform-azurerm-avm-res-communication-emailservice.git?ref=krbar/initialModuleVersion"
  name          = "emailsvc-auea-${random_pet.pet.id}"
  data_location = "Australia"

  domains = {
    kewalaka-nz = {
      name                             = "kewalaka.nz"
      domain_management                = "CustomerManaged"
      user_engagement_tracking_enabled = false
      sender_usernames = {
        sender_username0 = {
          name         = "notifications"
          username     = "notifications"
          display_name = "Notifications"
        }
        sender_username1 = {
          name         = "customerservice"
          username     = "customerservice"
          display_name = "Customer Service"
        }
      }
      role_assignments = {
        azure_app_writer = {
          role_definition_id_or_name = "AzureCommnicationServicesEmailWrite"
          principal_id               = azuread_service_principal.email_service_sp.id
        }
      }
    }
  }

  resource_group_name = azurerm_resource_group.this.name

  depends_on = [azapi_resource_action.communication_resource_provider]
}

// create a custom role for the Entra application used by the app to communicate with the email communication service
resource "azurerm_role_definition" "custom_role" {
  name        = "AzureCommnicationServicesEmailWrite"
  scope       = azurerm_resource_group.this.id
  description = "Custom role used by an Entra application to use the Email Communication Service"

  permissions {
    actions = [
      "Microsoft.Communication/CommunicationServices/Read",
      "Microsoft.Communication/CommunicationServices/Write",
      "Microsoft.Communication/EmailServices/Write"
    ]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.this.id
  ]
}

# Create a Microsoft Entra application
resource "azuread_application" "email_service_app" {
  display_name = "EmailServiceApp"
}

# Create a service principal for the application & client secret
resource "azuread_service_principal" "email_service_sp" {
  client_id = azuread_application.email_service_app.client_id
}

resource "azuread_application_password" "email_service_app_secret" {
  application_id    = azuread_application.email_service_app.id
  display_name      = "EmailServiceAppSecret"
  end_date_relative = "8760h" # 1 year
}
