<#
    .SYNOPSIS
        Dit script voegt firewallregels toe om Microsoft Teams videobellen mogelijk te maken.

    .DESCRIPTION
        Het script maakt gebruik van de 'netsh' opdracht om de benodigde firewallregels toe te voegen voor Microsoft Teams videobellen.

    .AUTHOR
        Fabio van der Burg

    .DATE
        15 augustus 2021
#>

# Parameters
$ruleName = "Allow Microsoft Teams Video Calling"
$programPath = "C:\Program Files (x86)\Microsoft\Teams\current\Teams.exe"

# Firewall regels toevoegen voor UDP en TCP
$ports = @(3478..3481)
$protocols = @("TCP", "UDP")

foreach ($protocol in $protocols) {
    foreach ($port in $ports) {
        $ruleExists = (Get-NetFirewallRule -DisplayName "$ruleName - $protocol Port $port" -ErrorAction SilentlyContinue) -ne $null

        if (!$ruleExists) {
            Write-Host "Adding firewall rule for Microsoft Teams $protocol Port $port"
            New-NetFirewallRule -DisplayName "$ruleName - $protocol Port $port" -Direction Inbound -Protocol $protocol -LocalPort $port -Program $programPath -Action Allow
        } else {
            Write-Host "Firewall rule for Microsoft Teams $protocol Port $port already exists"
        }
    }
}

# Firewall regel toevoegen voor het Microsoft Teams programma
$ruleExists = (Get-NetFirewallRule -DisplayName "$ruleName - Program" -ErrorAction SilentlyContinue) -ne $null

if (!$ruleExists) {
    Write-Host "Adding firewall rule for Microsoft Teams Program"
    New-NetFirewallRule -DisplayName "$ruleName - Program" -Direction Inbound -Program $programPath -Action Allow
} else {
    Write-Host "Firewall rule for Microsoft Teams Program already exists"
}

Write-Host "Microsoft Teams firewall rules added successfully."
