# reference: <https://learn.microsoft.com/en-us/azure/communication-services/quickstarts/email/send-email-smtp/smtp-authentication>
# should be: [The Azure Communication Service Resource name]|[The Microsoft Entra Application Registration (client) ID]|[The Microsoft Entra Tenant ID]
$smtpUser = "emailsvc-auea-evident-bullfrog|1d0ba261-4aaf-49a3-8224-b35d8aefa545|f7708992-6a22-4594-bf23-563e364d38f3" 
$smtpPass = $env:SMTP_PASSWORD # The client secret for the service principal
$from = "notifications@kewalaka.nz"
$to = "11kxwvcap@mozmail.com"
$subject = "Test Email" 
$body = "This is a test email sent from PowerShell using SMTP authentication."  

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
