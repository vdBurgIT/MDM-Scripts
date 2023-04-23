<#
    .SYNOPSIS
        Dit script voegt het huidige apparaat toe aan Autopilot via de Graph API.

    .DESCRIPTION
        Het script maakt gebruik van de Graph API om het apparaat toe te voegen aan Autopilot. Superhandig als je al een RMM tool op de devices hebt staan.

    .AUTHOR
        Fabio van der Burg

    .DATE
        4 oktober 2022

    .NOTES
        Vereisten:
        1. Maak een Azure AD App-registratie en configureer API-machtigingen met "DeviceManagementServiceConfig.ReadWrite.All".
        2. Noteer de Toepassings(Client)-ID, Directory(Tenant)-ID en het Clientgeheim.
        3. Vervang de placeholders in het script met de juiste waarden van de App-registratie.
#>

# Parameters
$tenantId = "<Directory(Tenant)-ID>"
$appId = "<Toepassings(Client)-ID>"
$clientSecret = "<Clientgeheim>"
$resource = "https://graph.microsoft.com"

# Verkrijg een toegangstoken
$tokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$tokenBody = @{
    grant_type    = "client_credentials"
    client_id     = $appId
    client_secret = $clientSecret
    scope         = "$resource/.default"
}

$tokenResponse = Invoke-RestMethod -Method Post -Uri $tokenUrl -ContentType "application/x-www-form-urlencoded" -Body $tokenBody
$accessToken = $tokenResponse.access_token

# Verkrijg het serienummer en het hardware-id van het apparaat
$serialNumber = (Get-WmiObject -Class "Win32_BIOS").SerialNumber
$hardwareId = (Get-WmiObject -Class "Win32_ComputerSystemProduct").UUID

# Maak de Autopilot-profiel payload
$autopilotPayload = @{
    "@odata.type"              = "#microsoft.graph.importedWindowsAutopilotDeviceIdentity"
    "orderIdentifier"          = "CustomOrderIdentifier"
    "serialNumber"             = $serialNumber
    "productKey"               = $hardwareId
    "importedDeviceIdentifier" = "CustomDeviceIdentifier"
}

# Converteer de payload naar JSON
$autopilotPayloadJson = $autopilotPayload | ConvertTo-Json

# API URL voor het toevoegen van het apparaat aan Autopilot
$autopilotApiUrl = "https://graph.microsoft.com/beta/deviceManagement/importedWindowsAutopilotDeviceIdentities"

# Voeg het apparaat toe aan Autopilot via de Graph API
try {
    $response = Invoke-RestMethod -Method Post -Uri $autopilotApiUrl -ContentType "application/json" -Headers @{Authorization = "Bearer $accessToken"} -Body $autopilotPayloadJson
    Write-Host "Het apparaat is succesvol toegevoegd aan Autopilot."
} catch {
    Write-Host "Er is een fout opgetreden bij het toevoegen van het apparaat aan Autopilot:"
    Write-Host $_.Exception.Response.StatusCode.value__
    Write-Host $_.Exception.Message
}