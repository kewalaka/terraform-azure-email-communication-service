$from = "notifications@kewalaka.nz"
$to = "11kxwvcap@mozmail.com"
$subject = "Test Email" 
$body = "This is a test email sent to Communication Services from PowerShell using SMTP authentication."  

# collect the inputs from the Terraform output variables
$values = terraform output -json | ConvertFrom-Json
$inputsMissing = $false
$tenantId = $values.azure_tenant_id.value
if ($null -eq $tenantId) {
  Write-Host "Azure tenant ID not found."
  $inputsMissing = $true
}
$app_client_id = $values.azuread_application_client_id.value
if ($null -eq $app_client_id) {
  Write-Host "Azure AD application client ID not found."
  $inputsMissing = $true
}
$commsvc_resource_name = $values.communication_service_resource_name.value
if ($null -eq $commsvc_resource_name) {
  Write-Host "Azure Communication Service resource name not found."
  $inputsMissing = $true
}
$app_secret = $values.email_service_app_secret.value
if ($null -eq $app_secret) {
  Write-Host "Azure AD application secret not found."
  $inputsMissing = $true
}

if ($inputsMissing) {
  Write-Host "One or more required inputs are missing, have you run Terraform locally?  Exiting."
  exit 1
}

# reference: <https://learn.microsoft.com/en-us/azure/communication-services/quickstarts/email/send-email-smtp/smtp-authentication>
# should be: [The Azure Communication Service Resource name]|[The Microsoft Entra Application Registration (client) ID]|[The Microsoft Entra Tenant ID]
$smtpUser = "$commsvc_resource_name|$app_client_id|$tenantId"
$smtpPass = $app_secret

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# message parameters
$message = @{
  To         = $to
  From       = $from
  Subject    = $subject
  Body       = $body
  SmtpServer = "smtp.azurecomm.net"
  Port       = 587
  UseSsl     = $true
  Credential = New-Object -TypeName PSCredential -ArgumentList $smtpUser, (ConvertTo-SecureString -AsPlainText -Force -String $smtpPass)
}

try {
  # this doesn't bail correctly when it fails :(
  Send-MailMessage @message
  Write-Host "Email sent successfully."
}
catch {
  Write-Host "Failed to send email. Error: $_"
}
