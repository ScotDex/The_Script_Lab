<#
.SYNOPSIS
    Scans a list of endpoints on a target URL to check their availability.

.DESCRIPTION
    This script iterates through a predefined list of endpoints and attempts to access each one using an HTTP GET request.
    It reports whether each endpoint is accessible or not.

.PARAMETER TargetURL
    The base URL of the target server to scan. This should be set before running the script.

.PARAMETER Endpoints
    An array of endpoint paths to be appended to the TargetURL for scanning.

.NOTES
    Author: GillenReidSynanetics
    FilePath: /GillenReidSynanetics/syn-support-operational-scripts/Troubleshooting/endpointscanner.ps1

.EXAMPLE
    # Set the target URL
    $TargetURL = "http://example.com"

    # Run the script to scan the endpoints
    .\endpointscanner.ps1

    This will output the status of each endpoint, indicating whether it was found or failed to respond.
#>
$TargetURL = "halo.tsg.com"
$Endpoints = @("/api/v1/", "/api/v2/", "/login", "/register", "/admin", "/users", "/search", "/health", "/status")

foreach ($Endpoint in $Endpoints) {
    $FullURL = "$TargetURL$Endpoint"
    try {
        $Response = Invoke-WebRequest -Uri $FullURL -UseBasicParsing -TimeoutSec 5
        if ($Response.StatusCode -eq 200) {
            Write-Host "[+] Found: $FullURL" -ForegroundColor Green
        } else {
            Write-Host "[-] No response: $FullURL"
        }
    } catch {
        Write-Host "[-] Failed: $FullURL"
    }
}

Invoke-RestMethod -Uri "https://halo.tsg.com/api/Category?type_id=1&tickettype_id=60&team_name=SUP%3A%201st%20line"

Invoke-RestMethod -Uri "https://halo.tsg.com/api/TicketType/60?includekbinfo=true" -Method POST 


Invoke-WebRequest -Uri "https://halo.tsg.com/auth/authorize?client_id=$(New-Guid)&response_type=code&redirect_uri=https%3A%2F%2Fhalo.tsg.com%2Fauth&scope=all&code_challenge=xyz123&code_challenge_method=S256&state=random123&nonce=testing123" -UseBasicParsing -Method Post



Invoke-RestMethod -Uri "
https://halo.tsg.com/api/TicketType/60?includekbinfo=true" -Method Put



35.177.100.199:443

$response = Invoke-WebRequest -Uri "https://halo.tsg.com/search?term=test" -UseBasicParsing
$response.Content


Invoke-RestMethod -Uri "https://halo.tsg.com/api/STATUS" -Method Delete -Headers @{ "Authorization" = "Bearer abc123xyz789tokenplaceholder"; "Accept" = "application/json" }



# Credentials (replace with real ones)
$username = "aidan.mcdermott@tsg.com"
$password = "1888"

# Encode for Basic Auth
$pair = "${username}:${password}"
$bytes = [System.Text.Encoding]::UTF8.GetBytes($pair)
$encoded = [Convert]::ToBase64String($bytes)

# Common headers
$headers = @{
    "Authorization" = "Basic $encoded"
    "Accept"        = "application/json"
}

# List of endpoints to test
$endpoints = @(
    "tickets",
    "tickets/1",
    "ticketnotes",
    "ticketstatuses",
    "tickettypes",
    "ticketpriorities",
    "tickettimes",
    "ticketactions",
    "clients",
    "contacts",
    "users",
    "technicians",
    "sites",
    "categories",
    "impactlevels",
    "urgencylevels",
    "slas",
    "configurations",
    "assets"
)

# Base URL
$baseUrl = "https://halo.tsg.com/api"

# Loop through each endpoint
foreach ($endpoint in $endpoints) {
    $url = "$baseUrl/$endpoint"
    try {
        $response = Invoke-WebRequest -Uri $url -Method GET -Headers $headers -ErrorAction Stop
        Write-Host "[200 OK]    $url"
    }
    catch {
        $status = $_.Exception.Response.StatusCode.value__
        Write-Host "[$status]    $url"
    }
}
