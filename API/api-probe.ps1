<#
.SYNOPSIS
    Probes a list of API endpoints on a target URL and displays their status and response details.

.DESCRIPTION
    This script iterates through a predefined list of API endpoints and sends HTTP GET requests to each endpoint on the specified target URL.
    It captures and displays the status code, response headers, and the first 500 characters of the response content if the endpoint is accessible.
    If the response content is in JSON format, it attempts to parse and display it in a readable format.

.PARAMETER TargetURL
    The base URL of the target server to probe.

.PARAMETER Endpoints
    An array of endpoint paths to append to the target URL for probing.

.EXAMPLE
    .\API-Probe-Print.ps1
    Probes the specified endpoints on the target URL and displays their status and response details.

.NOTES
    Author: Your Name
    Date: YYYY-MM-DD
    Version: 1.0
#>
$TargetURL = "halo.tsg.com"  # Set your target URL
$Endpoints = @("/api/v1/", "/api/v2/", "/login", "/register", "/admin", "/users", "/search", "/health", "/status")

foreach ($Endpoint in $Endpoints) {
    $FullURL = "$TargetURL$Endpoint"
    try {
        # Send request and capture response
        $Response = Invoke-WebRequest -Uri $FullURL -UseBasicParsing -TimeoutSec 5

        # If endpoint is accessible, display status and headers
        if ($Response.StatusCode -eq 200) {
            Write-Host "[+] Found: $FullURL" -ForegroundColor Green
            Write-Host "    Status Code: $($Response.StatusCode)"

            # Display response headers
            Write-Host "    Headers:"
            $Response.Headers | Format-Table -AutoSize

            # Attempt to parse JSON response
            if ($Response.Content -match "^\s*{") {
                Write-Host "    Response (JSON):"
                $JsonData = $Response.Content | ConvertFrom-Json -ErrorAction SilentlyContinue
                $JsonData | Format-List
            } else {
                Write-Host "    Response (Text):"
                $Response.Content.Substring(0, [Math]::Min($Response.Content.Length, 500)) # Show first 500 chars
            }
        }
    } catch {
        Write-Host "[-] Failed: $FullURL"
    }
}

