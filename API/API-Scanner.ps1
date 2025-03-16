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
$TargetURL = ""
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
